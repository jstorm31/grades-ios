//
//  LoginViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 01/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import Foundation
import RxCocoa
import RxSwift
import UIKit

final class LoginViewModel: BaseViewModel {
    typealias Dependencies = HasSceneCoordinator & HasAuthenticationService & HasGradesAPI & HasSettingsRepository
        & HasPushNotificationService & HasUserRepository & HasRemoteConfigService

    private let dependencies: Dependencies
    private let config = EnvironmentConfiguration.shared
    private let bag = DisposeBag()

    // MARK: output

    let displayGdprAlert = BehaviorSubject<Bool>(value: false)
    let fetching = BehaviorSubject<Bool>(value: false)
    let fetchingConfig = BehaviorSubject<Bool>(value: false)

    var openPrivacyPolicyLink = CocoaAction { _ in
        if let url = URL(string: EnvironmentConfiguration.shared.termsAndConditionsLink), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        return Observable<Void>.empty()
    }

    // MARK: input

    let gdprCompliant = BehaviorSubject<Bool?>(value: nil)

    // MARK: initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.dependencies.remoteConfigService.fetching.bind(to: fetchingConfig).disposed(by: bag)
    }

    deinit {
        dependencies.pushNotificationsService.stop()
    }

    // MARK: methods

    func authenticateWithRefresToken() -> Observable<Void> {
        if CommandLine.arguments.contains("--stub-authentication") {
            return Observable.empty()
        }

        fetching.onNext(true)
        return dependencies.remoteConfigService.mockData.skip(1)
            .flatMap { [weak self] mockData -> Observable<Bool> in
                if mockData {
                    return Observable.just(false)
                }

                self?.fetching.onNext(true)
                return self?.dependencies.authService.authenticateWitRefreshToken() ?? Observable.just(false)
            }
            .flatMap(postAuthSetup)
    }

    func authenticate(viewController: UIViewController) -> Observable<Void> {
        if CommandLine.arguments.contains("--stub-authentication") {
            return postAuthSetup(true)
        }

        fetching.onNext(true)
        return dependencies.remoteConfigService.mockData.take(1)
            .flatMap { [weak self] mockData -> Observable<Bool> in
                if mockData {
                    return Observable.just(true)
                }

                return self?.dependencies.authService
                    .authenticate(useBuiltInSafari: true, viewController: viewController) ?? Observable.just(false)
            }
            .flatMap(postAuthSetup)
    }

    func fetchRemoteConfig() {
        dependencies.remoteConfigService.fetchConfig()
    }
}

private extension LoginViewModel {
    func postAuthSetup(_ success: Bool) -> Observable<Void> {
        guard success == true else {
            fetching.onNext(false)
            return Observable.empty()
        }

        fetching.onNext(true)
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
                self?.fetching.onNext(false)
            })
    }

    /// Show GDPR and notification alerts if user is a student
    func handleGdpr(user: User, gdprState: GdprState?) -> Observable<Void> {
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

    func gdprSetup(for user: User) -> GdprState {
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

    func transitionToCourseList() {
        let courseListViewModel = CourseListViewModel(dependencies: AppDependency.shared)
        dependencies.coordinator.transition(to: .courseList(courseListViewModel), type: .push)
    }
}
