//
//  PushNotificationService.swift
//  Grades
//
//  Created by Jiří Zdvomka on 27/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import UIKit
import UserNotifications

protocol PushNotificationServiceProtocol {
    var deviceToken: PublishSubject<String> { get set }
    var isUserRegisteredForNotifications: Bool { get set }

    func start() -> Observable<Void>
    func stop()
}

protocol HasPushNotificationService {
    var pushNotificationsService: PushNotificationServiceProtocol { get set }
}

final class PushNotificationService: NSObject, PushNotificationServiceProtocol {
    typealias Dependencies = HasHttpService

    private let dependencies: Dependencies

    var deviceToken = PublishSubject<String>()

    var isUserRegisteredForNotifications: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "IsUserRegisteredForNotifications")
        }

        set {
            UserDefaults.standard.set(newValue, forKey: "IsUserRegisteredForNotifications")
        }
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

            return requestAuthorization()
                .flatMap { [weak self] granted -> Observable<String> in
                    if granted {
                        return self?.deviceToken.asObservable() ?? Observable.empty()
                    }
                    return Observable.empty()
                }
                .flatMap { [weak self] deviceToken -> Observable<Void> in
                    if let registered = self?.isUserRegisteredForNotifications, !registered {
                        return self?.registerUserForNotifications(token: deviceToken) ?? Observable.empty()
                    }
                    return Observable.just(())
                }
        #endif
    }

    func stop() {
        UIApplication.shared.unregisterForRemoteNotifications()
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
                    }
                } else {
                    observer.onNext(false)
                }
            }

            return Disposables.create()
        }
    }

    /// Register user with app's notification token
    private func registerUserForNotifications(token: String) -> Observable<Void> {
        let url = URL(string: "\(EnvironmentConfiguration.shared.notificationServerUrl)/token")!
        let body = NotificationRegistration(token: token, type: "IOS")

        return dependencies.httpService.post(url: url, parameters: nil, body: body)
            .do(onCompleted: { [weak self] in
                self?.isUserRegisteredForNotifications = true
            })
    }
}

extension PushNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("[NOTIFICATION_RECEIVE]", notification)
        completionHandler([.badge, .alert, .sound])
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("[NOTIFICATION_OPEN]", response)

        let userInfo = response.notification.request.content.userInfo
        print("[NOTIFICATION_USER_INFO]", userInfo)

//        let jsonData = try! JSONSerialization.data(withJSONObject: userInfo, options: [])
//
//        do {
//            let alertNotification = try JSONDecoder().decode(AlertNotification.self, from: jsonData)
//            notificationObserver.send(value: alertNotification)
//            print("[ALERT_NOTIFICATION]", alertNotification)
//        } catch {
//            print("[ALERT_NOTIFICATION]", error)
//        }

        completionHandler()
    }
}
