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

final class LoginViewModel: BaseViewModel {
    typealias Dependencies = HasAuthenticationService & HasGradesAPI & HasSettingsRepository
        & HasPushNotificationService& HasUserRepository

    var sceneCoordinator: SceneCoordinatorType!
    private let dependencies: Dependencies
    private let config = EnvironmentConfiguration.shared

    // MARK: initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    deinit {
        dependencies.pushNotificationsService.stop()
    }

    // MARK: methods

    func authenticateWithRefresToken() -> Observable<Void> {
        if CommandLine.arguments.contains("--stub-authentication") {
            return Observable.empty()
        }

        return dependencies.authService.authenticateWitRefreshToken()
            .flatMap(postAuthSetup)
    }

    func authenticate(viewController: UIViewController) -> Observable<Void> {
        if CommandLine.arguments.contains("--stub-authentication") {
            return postAuthSetup(true)
        }

        return dependencies.authService
            .authenticate(useBuiltInSafari: true, viewController: viewController)
            .flatMap(postAuthSetup)
    }

    private func postAuthSetup(_ success: Bool) -> Observable<Void> {
        guard success == true else {
            return Observable.empty()
        }

        return dependencies.pushNotificationsService.start()
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
