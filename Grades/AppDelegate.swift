//
//  AppDelegate.swift
//  Classification
//
//  Created by Jiří Zdvomka on 25/02/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

#if DEBUG
    import Bagel
#endif

import OAuthSwift
import Sentry
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        resetStateIfUITesting()

        // Initialize first scene
        let loginViewModel = LoginViewModel(dependencies: AppDependency.shared)
        let loginScene = Scene.login(loginViewModel)

        // Window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = loginScene.viewController()
        AppDependency.shared.coordinator.setRoot(viewController: window!.rootViewController!)

        // Process notification
        processNotification(options)
        setupSentry()

        #if DEBUG
            Bagel.start()
        #endif

        return true
    }

    func application(_: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let sourceApp = options[.sourceApplication] as? String
        let isOpenedBySafari = sourceApp == "com.apple.SafariViewService" || sourceApp == "com.apple.mobilesafari"

        if isOpenedBySafari, url.host == EnvironmentConfiguration.shared.auth.callbackId {
            OAuthSwift.handle(url: url)
        }

        return true
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenObservable = AppDependency.shared.pushNotificationsService.deviceToken
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        tokenObservable.onNext(token)
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        let tokenObservable = AppDependency.shared.pushNotificationsService.deviceToken
        tokenObservable.onError(error)
    }

    func applicationDidBecomeActive(_: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

private extension AppDelegate {
    func resetStateIfUITesting() {
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            let settings = Settings(language: .english,
                                    semester: "B182",
                                    sendingNotificationsEnabled: false,
                                    undefinedEvaluationHidden: false)

            // Reset semester
            if let encoded = try? JSONEncoder().encode(settings) {
                UserDefaults.standard.set(encoded, forKey: "Settings")
            }
        }
    }

    func setupSentry() {
        do {
            Client.shared = try Client(dsn: EnvironmentConfiguration.shared.sentryUrl)
            try Client.shared?.startCrashHandler()
        } catch {
            Log.error("Sentry initialization: \(error.localizedDescription)")
        }
    }

    func processNotification(_ options: [UIApplication.LaunchOptionsKey: Any]?) {
        let service = AppDependency.shared.pushNotificationsService

        // Get username and mark the notification as read
        guard let userInfo = options?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: AnyObject],
            let notification = PushNotification.decode(from: userInfo) else {
            service.decreaseNotificationCount()
            return
        }

        service.currentNotification.accept(notification)
    }
}
