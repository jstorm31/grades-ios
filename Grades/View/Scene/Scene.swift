//
//  Sceen.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

enum Scene {
    case login(LoginViewModel)
    case courseList(CourseListViewModel)
    case courseDetailStudent(CourseDetailStudentViewModel)
}

extension Scene {
    func viewController() -> UIViewController {
        switch self {
        case let .login(viewModel):
            var loginVC = LoginViewController()
            loginVC.bindViewModel(to: viewModel)
            return loginVC

        case let .courseList(viewModel):
            var courseListVC = CourseListViewController()
            let navController = UINavigationController(rootViewController: courseListVC)
            courseListVC.bindViewModel(to: viewModel)
            return navController

        case let .courseDetailStudent(viewModel):
            var courseDetailStudentVC = CourseDetailStudentViewController()
            let navController = UINavigationController(rootViewController: courseDetailStudentVC)
            courseDetailStudentVC.bindViewModel(to: viewModel)
            return navController
        }
    }
}
