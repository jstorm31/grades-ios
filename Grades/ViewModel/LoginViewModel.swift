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
    typealias Dependencies = HasSceneCoordinator & HasAuthenticationService & HasGradesAPI & HasSettingsRepository
        & HasPushNotificationService & HasUserRepository

    private let dependencies: Dependencies
    private let config = EnvironmentConfiguration.shared

    // MARK: output

    let displayGdprAlert = BehaviorSubject<Bool>(value: false)

    // MARK: input

    let gdprCompliant = BehaviorSubject<Bool?>(value: nil)

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

        let gdprState = gdprSetup()

        return gdprCompliant
            .unwrap()
            .do(onNext: { isCompliant in
                if case .unset = gdprState {
                    UserDefaults.standard.set(isCompliant ? GdprState.accepted.rawValue : GdprState.declined.rawValue,
                                              forKey: Constants.gdprCompliant)
                }
            })
            .flatMap { [weak self] isCompliant -> Observable<Void> in
                if isCompliant {
                    return self?.dependencies.pushNotificationsService.start() ?? Observable.empty()
                }
                return Observable.just(())
            }
            .take(1)
            .map { _ in }
            .flatMap(dependencies.settingsRepository.fetchCurrentSemester)
            .map { _ in }
            .flatMap(dependencies.gradesApi.getUser)
            .debug()
            .do(onNext: { [weak self] user in
                self?.gdprCompliant.onNext(nil) // Clear state to prevent auto log in on next time
                self?.dependencies.userRepository.user.accept(user)
                self?.transitionToCourseList()
            })
            .map { _ in }
    }

    @discardableResult
    private func gdprSetup() -> GdprState {
        let gdprState = GdprState(rawValue: UserDefaults.standard.integer(forKey: Constants.gdprCompliant)) ?? .unset

        switch gdprState {
        case .unset:
            displayGdprAlert.onNext(true)
        case .accepted:
            gdprCompliant.onNext(true)
        case .declined:
            gdprCompliant.onNext(false)
        }

        return gdprState
    }

    private func transitionToCourseList() {
        let courseListViewModel = CourseListViewModel(dependencies: AppDependency.shared)
        dependencies.coordinator.transition(to: .courseList(courseListViewModel), type: .modal)
    }
}
