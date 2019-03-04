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
    case subjectList(SubjectListViewModel)
}

extension Scene {
    func viewController() -> UIViewController {
        switch self {
        case let .login(viewModel):
            var vc = LoginViewController()
            vc.bindViewModel(to: viewModel)
            return vc
        case let .subjectList(viewModel):
            var vc = SubjectListViewController()
            vc.bindViewModel(to: viewModel)
            return vc
        }
    }
}
