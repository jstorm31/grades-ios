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
    case settings(SettingsViewModel)
    case teacherClassification(TeacherClassificationViewModel)
    case groupClassification(GroupClassificationViewModel)
    case studentClassification(StudentClassificationViewModel)
    case studentSearch(StudentSearchViewModel)
    case text(TextViewModel)
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
            courseDetailStudentVC.bindViewModel(to: viewModel)
            return courseDetailStudentVC

        case let .settings(viewModel):
            var settingsVC = SettingsViewController()
            settingsVC.bindViewModel(to: viewModel)
            return settingsVC

        case let .teacherClassification(viewModel):
            var teacherClassificationVC = TeacherClassificationViewController()
            teacherClassificationVC.bindViewModel(to: viewModel)
            return teacherClassificationVC

        case let .groupClassification(viewModel):
            var groupClassificationVC = GroupClassificationViewController()
            groupClassificationVC.bindViewModel(to: viewModel)
            return groupClassificationVC

        case let .studentClassification(viewModel):
            var studentClassificationVc = StudentClassificationViewController()
            studentClassificationVc.bindViewModel(to: viewModel)
            return studentClassificationVc

        case let .studentSearch(viewModel):
            var studentSearchVC = StudentSearchViewController()
            studentSearchVC.bindViewModel(to: viewModel)
            return studentSearchVC

        case let .text(viewModel):
            var textVC = TextViewController()
            textVC.bindViewModel(to: viewModel)
            return textVC
        }
    }
}
