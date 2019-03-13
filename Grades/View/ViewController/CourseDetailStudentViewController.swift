//
//  CourseDetailStudentViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 11/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxCocoa
import UIKit

class CourseDetailStudentViewController: BaseViewController, BindableType {
    var viewModel: CourseDetailStudentViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.course.code
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            viewModel.onBack.execute()
        }
    }

    func bindViewModel() {}
}
