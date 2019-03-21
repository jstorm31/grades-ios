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

protocol LoginViewModelProtocol {
    func authenticate(viewController: UIViewController) -> Observable<Void>
}

final class LoginViewModel: BaseViewModel {
    typealias Dependencies = HasAuthenticationService & HasGradesAPI

    private let dependencies: Dependencies
    private let sceneCoordinator: SceneCoordinatorType
    private let config = EnvironmentConfiguration.shared
    private let bag = DisposeBag()

    // MARK: initialization

    init(dependencies: Dependencies, sceneCoordinator: SceneCoordinatorType) {
        self.dependencies = dependencies
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: methods

    func authenticate(viewController: UIViewController) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            self?.dependencies.authService
                .authenticate(useBuiltInSafari: false, viewController: viewController)
                .subscribe(onError: { error in
                    observer.onError(error)
                }, onCompleted: { [weak self] in
                    guard let self = self else { return }

                    let user = self.dependencies.gradesApi.getUser()
                    let code = self.dependencies.gradesApi.getCurrentSemestrCode()
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
        // TODO: refactor to dependency injection and move semester code fetching logic to settings repository
        let settings = SettingsRepository(authClient: dependencies.authService.handler.client, currentSemesterCode: semesterCode)
        dependencies.gradesApi.set(settings: settings)

        let courseListViewModel = CourseListViewModel(dependencies: AppDependency.shared, sceneCoordinator: sceneCoordinator, user: user, settings: settings)

        // Transition to course list scene
        sceneCoordinator.transition(to: .courseList(courseListViewModel), type: .modal)
    }
}
