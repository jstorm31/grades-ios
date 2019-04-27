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
    func start() -> Observable<Bool>
    func stop()
}

protocol HasPushNotificationService {
    var pushNotificationsService: PushNotificationServiceProtocol { get }
}

final class PushNotificationService: NSObject, PushNotificationServiceProtocol {
    typealias Dependencies = HasNoDependency

    init(dependencies _: Dependencies) {
        super.init()
    }

    func start() -> Observable<Bool> {
        return Observable.create { observer in

            if #available(iOS 10.0, *) {
                // For iOS 10 display notification (sent via APNS)
                UNUserNotificationCenter.current().delegate = self

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
            } else {
                let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
                observer.onNext(true)
                observer.onCompleted()
            }

            UIApplication.shared.registerForRemoteNotifications()
            UNUserNotificationCenter.current().delegate = self

            return Disposables.create()
        }
    }

    func stop() {
        UIApplication.shared.unregisterForRemoteNotifications()
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
