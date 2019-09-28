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

        return dependencies.gradesApi.getUser()
            .do(onNext: { [weak self] user in
                // Save fetched user data
                self?.dependencies.userRepository.user.accept(user)
            })
            .map { [weak self] user in
                // Get GDPR state (if user is a student) and forward user data
                var gdprState: GdprState?

                if user.isStudent {
                    gdprState = self?.gdprSetup(for: user)
                }
                return (user, gdprState)
            }
            .flatMap(handleGdpr)
            .flatMap(dependencies.settingsRepository.fetchCurrentSemester)
            .map { _ in }
            .do(onNext: { [weak self] _ in
                self?.transitionToCourseList()
            })
    }

    /// Show GDPR and notification alerts if user is a student
    private func handleGdpr(user: User, gdprState: GdprState?) -> Observable<Void> {
        guard let gdprState = gdprState, user.isStudent else {
            return Observable.just(())
        }

        return gdprCompliant
            .unwrap()
            .take(1)
            .do(onNext: { isCompliant in
                if case .unset = gdprState {
                    // Save new state
                    UserDefaults.standard.set(isCompliant ? GdprState.accepted.rawValue : GdprState.declined.rawValue,
                                              forKey: Constants.gdprCompliantKey(for: user.username))
                }
            })
            .flatMap { [weak self] isCompliant -> Observable<Void> in
                // Start the notification service
                if isCompliant {
                    return self?.dependencies.pushNotificationsService.start() ?? Observable.empty()
                }
                return Observable.just(())
            }
    }

    private func gdprSetup(for user: User) -> GdprState {
        let gdprValue = UserDefaults.standard.integer(forKey: Constants.gdprCompliantKey(for: user.username))
        let gdprState = GdprState(rawValue: gdprValue) ?? .unset

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
