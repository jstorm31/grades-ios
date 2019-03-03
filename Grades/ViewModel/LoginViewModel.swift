//
//  LoginViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 01/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

struct LoginViewModel {
    let sceneCoordinator: SceneCoordinatorType
    private let authService = AuthenticationService()

    func authenticate(viewController: UIViewController) -> Observable<Void> {
        return authService.authenticate(useBuiltInSafari: true, viewController: viewController)
    }
}
