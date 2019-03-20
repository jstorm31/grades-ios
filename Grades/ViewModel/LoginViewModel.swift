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

class LoginViewModel: BaseViewModel {
    // MARK: properties

    let sceneCoordinator: SceneCoordinatorType
    let authService: AuthenticationServiceProtocol
    let httpService: HttpServiceProtocol
    var gradesApi: GradesAPIProtocol
    let config = EnvironmentConfiguration.shared
    private let bag = DisposeBag()

    // MARK: methods

    init(sceneCoordinator: SceneCoordinatorType,
         authenticationService: AuthenticationServiceProtocol,
         httpService: HttpServiceProtocol,
         gradesApi: GradesAPIProtocol) {
        self.sceneCoordinator = sceneCoordinator
        self.httpService = httpService
        self.gradesApi = gradesApi
        authService = authenticationService
    }

    func authenticate(viewController: UIViewController) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            self?.authService
                .authenticate(useBuiltInSafari: false, viewController: viewController)
                .subscribe(onError: { error in
                    observer.onError(error)
                }, onCompleted: { [weak self] in
                    guard let self = self else { return }

                    let user = self.gradesApi.getUser()
                    let code = self.gradesApi.getCurrentSemestrCode()
                    Observable.zip(user, code) { (userInfo: UserInfo, semesterCode: String) -> (UserInfo, String) in (userInfo, semesterCode) }
                        .subscribe(onNext: { [weak self] userInfo, semesterCode in
                            self?.transitionToCourseList(user: userInfo, semesterCode: semesterCode)
                            observer.onCompleted()
                        })
                        .disposed(by: self.bag)
                })
                .disposed(by: self?.bag ?? DisposeBag())

            return Disposables.create()
        }
    }

    private func transitionToCourseList(user: UserInfo, semesterCode: String) {
        let kosApi = KosApi(client: authService.handler.client, configuration: config.kosAPI)

        let settings = SettingsRepository(authClient: authService.handler.client, currentSemesterCode: semesterCode)
        gradesApi.settings = settings

        let courseListViewModel = CourseListViewModel(sceneCoordinator: sceneCoordinator, gradesApi: gradesApi, kosApi: kosApi, user: user, settings: settings)

        // Transition to course list scene
        sceneCoordinator.transition(to: .courseList(courseListViewModel), type: .modal)
    }
}
