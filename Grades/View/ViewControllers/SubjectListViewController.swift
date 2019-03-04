//
//  SubjectListViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

class SubjectListViewController: BaseViewController, BindableType {
    // MARK: UI elements

    // MARK: properties

    var viewModel: SubjectListViewModel!
    var bag = DisposeBag()

    // MARK: Lifecycle methods

    override func loadView() {
        super.loadView()

        let label = UILabel()
        label.text = "Subjects"
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.fetchUser()
            .subscribe(onNext: { user in
                print(user)
            })
            .disposed(by: bag)

        viewModel.fetchSubjects()
            .subscribe(onNext: { json in
                print("\n============= Success ================")
                print(json)
            }, onError: { error in
                print("\n==============Error ================")
                print(error)
            })
            .disposed(by: bag)
    }

    // MARK: methods

    func bindViewModel() {}
}
