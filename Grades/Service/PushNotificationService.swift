//
//  PushNotificationService.swift
//  Grades
//
//  Created by Jiří Zdvomka on 27/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import FirebaseInstanceID
import RxSwift
import UIKit
import UserNotifications

protocol PushNotificationServiceProtocol {
    var isUserRegisteredForNotifications: Bool { get set }

    func start() -> Observable<Bool>
    func stop()
}

protocol HasPushNotificationService {
    var pushNotificationsService: PushNotificationServiceProtocol { get set }
}

final class PushNotificationService: NSObject, PushNotificationServiceProtocol {
    typealias Dependencies = HasHttpService

    var isUserRegisteredForNotifications: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "IsUserRegisteredForNotifications")
        }

        set {
            UserDefaults.standard.set(newValue, forKey: "IsUserRegisteredForNotifications")
        }
    }

    // MARK: Private properties

    private let dependencies: Dependencies
    private let bag = DisposeBag()

    // MARK: Errors

    enum NotificationError: Error {
        case noDeviceToken
        case couldNotComplete
    }

    // MARK: Initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init()
    }

    // MARK: Methods

    func start() -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }

            // Request authorization
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, _ in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    observer.onNext(false)
                    observer.onCompleted()
                }
            }
            UNUserNotificationCenter.current().delegate = self

            // Register user for notifications
            if !self.isUserRegisteredForNotifications {
                self.fetchToken()
                    .flatMap { [weak self] token in
                        self?.registerUserForNotifications(token: token) ?? Observable.empty()
                    }
                    .subscribe(onError: { error in
                        Log.error("PushNotificationService:start: \(error)")
                        observer.onError(error)
                    }, onCompleted: {
                        observer.onNext(true)
                        observer.onCompleted()
                    })
                    .disposed(by: self.bag)
            } else {
                observer.onNext(true)
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    func stop() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }

    // MARK: Private methods

    private func fetchToken() -> Observable<String> {
        return Observable.create { observer in
            InstanceID.instanceID().instanceID { result, error in
                if let error = error {
                    Log.error("Error getting notification token: \(error)")
                    observer.onError(error)
                } else if let result = result {
                    observer.onNext(result.token)
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }

    /// Register user with app's notification token
    private func registerUserForNotifications(token: String) -> Observable<Void> {
        let url = URL(string: "\(EnvironmentConfiguration.shared.notificationServerUrl)/token")!
        let body = NotificationRegistration(token: token, type: "ANDROID") // Set type "ANDROID" because notifications are handled by Firebase, not APNs

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
