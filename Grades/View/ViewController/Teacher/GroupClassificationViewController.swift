//
//  GroupClassificationViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

class GroupClassificationViewController: BaseTableViewController, BindableType {
    // MARK: properties

    private let bag = DisposeBag()

    var viewModel: GroupClassificationViewModelProtocol!

    // MARK: lifecycle

    override func loadView() {
        loadView(hasTableHeaderView: false)
        view.backgroundColor = .yellow
        loadUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.bindOutput()
    }

    // MARK: methods

    func bindViewModel() {
        viewModel.groupOptions.asObservable()
            .subscribe(onNext: {
                Log.info("Groups: \($0)")
            })
            .disposed(by: bag)

        viewModel.classificationOptions.asObservable()
            .subscribe(onNext: {
                Log.info("Classification: \($0)")
            })
            .disposed(by: bag)

        viewModel.isloading.asDriver(onErrorJustReturn: false)
            .drive(view.rx.refreshing)
            .disposed(by: bag)

        viewModel.error.asDriver(onErrorJustReturn: ApiError.general)
            .drive(view.rx.errorMessage)
            .disposed(by: bag)
    }

    // MARK: UI setup

    func loadUI() {}
}
