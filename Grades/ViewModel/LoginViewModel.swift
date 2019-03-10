//
//  LoginViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 01/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

class LoginViewModel {
    // MARK: properties

    let sceneCoordinator: SceneCoordinatorType
    let authService: AuthenticationServiceProtocol
    let httpService: HttpServiceProtocol
    let gradesApi: GradesAPIProtocol
    let config: NSClassificationConfiguration
    private let bag = DisposeBag()

    // MARK: methods

    init(sceneCoordinator: SceneCoordinatorType,
         configuration: NSClassificationConfiguration,
         authenticationService: AuthenticationServiceProtocol,
         httpService: HttpServiceProtocol,
         gradesApi: GradesAPIProtocol) {
        self.sceneCoordinator = sceneCoordinator
        self.httpService = httpService
        self.gradesApi = gradesApi
        config = configuration
        authService = authenticationService
    }

    func authenticate(viewController: UIViewController) -> Observable<UserInfo> {
        return authService
            .authenticate(useBuiltInSafari: false, viewController: viewController)
            .map { _ in Void() }
            .flatMap(gradesApi.getUser)
            .do(onNext: { [weak self] userInfo in
                guard let `self` = self else { return }

                // Transition to course list scene
                let courseListViewModel = CourseListViewModel(api: self.gradesApi, user: userInfo)
                self.sceneCoordinator.transition(to: .courseList(courseListViewModel), type: .modal)
            })
    }
}
