//
//  CourseDetailStudentViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 11/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxCocoa
import RxSwift
import UIKit

class CourseDetailStudentViewController: BaseViewController, BindableType {
    var viewModel: CourseDetailStudentViewModel!
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.courseCode
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            viewModel.onBack.execute()
        }
    }

    func bindViewModel() {
        viewModel.classifications
            .subscribe(onNext: {
                Log.info("Received: \($0)")
            }, onError: {
                Log.error("\($0)")
            })
            .disposed(by: bag)
    }
}
