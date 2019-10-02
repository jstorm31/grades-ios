//
//  PushNotificationService.swift
//  Grades
//
//  Created by Jiří Zdvomka on 27/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit
import UserNotifications

protocol PushNotificationServiceProtocol {
    var deviceToken: BehaviorSubject<String?> { get set }
    var isUserRegisteredForNotifications: Bool { get set }

    func start() -> Observable<Void>
    func stop()
    func unregisterUserFromDevice() -> Observable<Void>
}

protocol HasPushNotificationService {
    var pushNotificationsService: PushNotificationServiceProtocol { get set }
}

final class PushNotificationService: NSObject, PushNotificationServiceProtocol {
    typealias Dependencies = HasHttpService & HasGradesAPI & HasUserRepository & HasSceneCoordinator

    private let dependencies: Dependencies
    private let tokenUrl = URL(string: "\(EnvironmentConfiguration.shared.notificationServerUrl)/token")!
    private let bag = DisposeBag()

    var deviceToken = BehaviorSubject<String?>(value: nil)

    var isUserRegisteredForNotifications: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constants.userRegisteredForNotifications)
        }

        set {
            UserDefaults.standard.set(newValue, forKey: Constants.userRegisteredForNotifications)
        }
    }

    enum NotificationError: Error {
        case tokenIsNil
    }

    // MARK: Initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init()
    }

    // MARK: Methods

    /**
     Start and configure push notifications
     - request user's authorization
     - register user with device on notification server
     - register for notifications

     - Returns: observable sequence emmitting true when access has been granted and flase if it has not.
     */
    func start() -> Observable<Void> {
        #if targetEnvironment(simulator)
            return Observable.just(())
        #else
            UNUserNotificationCenter.current().delegate = self

            return Observable.create { [weak self] observer in
                guard let self = self else { return Disposables.create() }

                self.requestAuthorization()
                    .flatMap { [weak self] granted -> Observable<String?> in
                        if granted {
                            return self?.deviceToken.asObservable() ?? Observable.empty()
                        }
                        return Observable.empty()
                    }
                    .unwrap()
                    .take(1)
                    .flatMap { [weak self] deviceToken -> Observable<Void> in
                        if let registered = self?.isUserRegisteredForNotifications, !registered {
                            return self?.registerUserForNotifications(token: deviceToken) ?? Observable.empty()
                        }
                        return Observable.just(())
                    }
                    .subscribe(onNext: {
                        observer.onNext(())
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    })
                    .disposed(by: self.bag)

                return Disposables.create()
            }

        #endif
    }

    func stop() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }

    /// Unregisters user from device on notification server
    func unregisterUserFromDevice() -> Observable<Void> {
        isUserRegisteredForNotifications = false

        return deviceToken
            .take(1)
            .flatMap { [weak self] token -> Observable<Void> in
                guard let self = self, let token = token else {
                    return Observable.error(NotificationError.tokenIsNil)
                }

                let body = NotificationRegistration(token: token, type: Constants.iosDeviceType)
                return self.dependencies.httpService.delete(url: self.tokenUrl, parameters: nil, body: body)
            }
    }

    // MARK: Private methods

    /// Reactive wrapper over requestAuthorization
    private func requestAuthorization() -> Observable<Bool> {
        return Observable.create { observer in
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, _ in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                } else {
                    observer.onNext(false)
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }

    /// Register user with app's notification token
    private func registerUserForNotifications(token: String) -> Observable<Void> {
        return deviceToken
            .unwrap()
            .take(1)
            .flatMap { [weak self] token -> Observable<Void> in
                guard let self = self else {
                    return Observable.error(NotificationError.tokenIsNil)
                }
                let body = NotificationRegistration(token: token, type: Constants.iosDeviceType)
                return self.dependencies.httpService.post(url: self.tokenUrl, parameters: nil, body: body)
            }
            .do(onCompleted: { [weak self] in
                self?.isUserRegisteredForNotifications = true
            })
    }
}

extension PushNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .alert, .sound])
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // Get username and mark the notification as read
        if let id = userInfo["notificationId"] as? String, let notificationId = Int(id) {
            dependencies.userRepository.user.asObservable().unwrap()
                .map { $0.username }
                .flatMap { [weak self] username -> Observable<Void> in
                    self?.dependencies.gradesApi.markNotificationRead(username: username, notificationId: notificationId)
                        ?? Observable.empty()
                }
                .subscribe(onNext: { _ in }).disposed(by: bag)
        }

        // Present course detail screne
        if let courseCode = userInfo["courseCode"] as? String {
            let courseDetailVM = CourseDetailStudentViewModel(dependencies: AppDependency.shared, course: Course(code: courseCode))
            dependencies.coordinator.transition(to: .courseDetailStudent(courseDetailVM), type: .push)
        }

        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
}
