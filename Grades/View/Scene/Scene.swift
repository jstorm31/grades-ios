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
}

extension Scene {
    func viewController() -> UIViewController {
        switch self {
        case let .login(viewModel):
            var loginVC = LoginViewController()
            loginVC.bindViewModel(to: viewModel)
            return loginVC
        case let .courseList(viewModel):
            var subjectListVC = CourseListViewController()
            subjectListVC.bindViewModel(to: viewModel)
            let navController = UINavigationController(rootViewController: subjectListVC)
            return navController
        }
    }
}
