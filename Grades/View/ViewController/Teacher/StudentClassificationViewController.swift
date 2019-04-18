//
//  StudentClassificationViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class StudentClassificationViewController: BaseTableViewController, BindableType {
    var viewModel: StudentClassificationViewModel!
    private let bag = DisposeBag()

    // MARK: lifecycle methods

    override func loadView() {
        loadView(hasTableHeaderView: false)
        loadUI()
    }

    override func viewDidLoad() {
        viewModel.bindOutput()
    }

    // MARK: binding

    func bindViewModel() {
        viewModel.studentName.subscribe(onNext: { Log.debug("User: \($0)") }).disposed(by: bag)

        let loading = viewModel.isloading.share(replay: 1, scope: .whileConnected)

        loading.asDriver(onErrorJustReturn: false)
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: bag)

        loading.asDriver(onErrorJustReturn: false)
            .debug()
            .drive(view.rx.refreshing)
            .disposed(by: bag)

        viewModel.error.asDriver(onErrorJustReturn: ApiError.general)
            .drive(view.rx.errorMessage)
            .disposed(by: bag)
    }

    // MARK: UI setup

    private func loadUI() {
        loadRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
    }

    // MARK: events

    @objc private func refreshControlPulled(_: UIRefreshControl) {
        viewModel.bindOutput()
    }
}
