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
    let authService: AuthenticationService
    let config: EnvironmentConfiguration
    private let bag = DisposeBag()

    let isLoading = PublishSubject<Bool>()
    let authError = PublishSubject<Error>()

    // MARK: methods

    init(sceneCoordinator: SceneCoordinatorType, configuration: EnvironmentConfiguration) {
        self.sceneCoordinator = sceneCoordinator
        config = configuration
        authService = AuthenticationService(configuration: configuration)
    }

    func authenticate(viewController: UIViewController) {
        authService
            .authenticate(useBuiltInSafari: false, viewController: viewController)
            .do(onError: { [weak self] error in
                guard let `self` = self else { return }
                Observable.just(error).bind(to: self.authError).disposed(by: self.bag)
            }, onCompleted: { [weak self] in
                guard let `self` = self else { return }

                let httpService = HttpService(client: self.authService.handler.client)
                let gradesApi = GradesAPI(httpService: httpService, configuration: self.config)

                gradesApi.getUser()
                    .subscribe(onNext: { [weak self] userInfo in
                        guard let `self` = self else { return }

                        // Transition to course list scene
                        let courseListViewModel = CourseListViewModel(api: gradesApi, user: userInfo)
                        self.sceneCoordinator.transition(to: .subjectList(courseListViewModel), type: .modal)
                    }, onError: { [weak self] error in
                        guard let `self` = self else { return }
                        Observable.just(error).bind(to: self.authError).disposed(by: self.bag)
                    })
                    .disposed(by: self.bag)
            })
            .monitorLoading()
            .loading()
            .bind(to: isLoading)
            .disposed(by: bag)
    }
}
