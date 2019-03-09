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

class LoginViewModel {
    // MARK: properties

    let sceneCoordinator: SceneCoordinatorType
    let authService: AuthenticationService
    let config: EnvironmentConfiguration
    private let bag = DisposeBag()

    let isLoading = PublishSubject<Bool>()

    // MARK: methods

    init(sceneCoordinator: SceneCoordinatorType, configuration: EnvironmentConfiguration) {
        self.sceneCoordinator = sceneCoordinator
        config = configuration
        authService = AuthenticationService(configuration: configuration)
    }

    func authenticate(viewController: UIViewController) -> Observable<Void> {
        let subscription = authService
            .authenticate(useBuiltInSafari: false, viewController: viewController)
            .do(onCompleted: { [weak self] in
                guard let `self` = self else { return }

                let httpService = HttpService(client: self.authService.handler.client)
                let gradesApi = GradesAPI(httpService: httpService, configuration: self.config)

                let subjectListViewModel = CourseListViewModel(api: gradesApi)
                self.sceneCoordinator.transition(to: .subjectList(subjectListViewModel), type: .modal)
            })
            .share()

        subscription
            .monitorLoading()
            .loading()
            .bind(to: isLoading)
            .disposed(by: bag)

        return subscription
    }
}
