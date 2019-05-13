//
//  AppDelegate.swift
//  Classification
//
//  Created by Jiří Zdvomka on 25/02/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import OAuthSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        resetStateIfUITesting()

        // Initialize first scene
        let loginViewModel = LoginViewModel(dependencies: AppDependency.shared)
        let loginScene = Scene.login(loginViewModel)

        // Window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = loginScene.viewController()
        AppDependency.shared.coordinator.setRoot(viewController: window!.rootViewController!)

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
        Log.debug("Token: \(token)")
        tokenObservable.accept(token)
    }

    private func resetStateIfUITesting() {
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            // Reset semester
            if let encoded = try? JSONEncoder().encode(Settings(language: .english, semester: "B182")) {
                UserDefaults.standard.set(encoded, forKey: "Settings")
            }
        }
    }
}
