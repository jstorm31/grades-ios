//
//  LoginViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 01/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxSwift

class LoginViewModel {
    private let authService = AuthenticationService()

    func authenticate(viewController: ViewController) -> Observable<Void> {
        return authService.authenticate(useBuiltInSafari: true, viewController: viewController)
    }
}
