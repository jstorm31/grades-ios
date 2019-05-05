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
    typealias Dependencies = HasAuthenticationService & HasGradesAPI & HasSettingsRepository
        & HasPushNotificationService& HasUserRepository

    private let dependencies: Dependencies
    private let sceneCoordinator: SceneCoordinatorType
    private let config = EnvironmentConfiguration.shared

    // MARK: initialization

    init(dependencies: Dependencies, sceneCoordinator: SceneCoordinatorType) {
        self.dependencies = dependencies
        self.sceneCoordinator = sceneCoordinator
    }

    deinit {
        dependencies.pushNotificationsService.stop()
    }

    // MARK: methods

    func authenticate(viewController: UIViewController) -> Observable<Void> {
        if CommandLine.arguments.contains("--stub-authentication") {
            return Observable.just(()).do(onNext: { _ in
                self.transitionToCourseList()
            })
        }

        return dependencies.authService
            .authenticate(useBuiltInSafari: false, viewController: viewController)
            .filter { $0 == true }
            .flatMap { [weak self] _ in
                self?.dependencies.pushNotificationsService.start() ?? Observable.empty()
            }
            .map { _ in }
            .flatMap(dependencies.settingsRepository.fetchCurrentSemester)
            .map { _ in }
            .flatMap(dependencies.gradesApi.getUser)
            .do(onNext: { [weak self] user in
                self?.dependencies.userRepository.user.accept(user)
                self?.transitionToCourseList()
            })
            .map { _ in }
    }

    private func transitionToCourseList() {
        let courseListViewModel = CourseListViewModel(dependencies: AppDependency.shared, sceneCoordinator: sceneCoordinator)
        sceneCoordinator.transition(to: .courseList(courseListViewModel), type: .modal)
    }
}
