//
//  AppDelegate.swift
//  Classification
//
//  Created by Jiří Zdvomka on 25/02/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Bagel
import OAuthSwift // TODO: remove on release!
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = LoginViewController()

        Bagel.start() // TODO: remove on release!

        // Initialize and transition to first screen
        let sceneCoordinator = SceneCoordinator(window: window!)
        let loginViewModel = LoginViewModel(dependencies: AppDependency.shared, sceneCoordinator: sceneCoordinator)
        let loginScreen = Scene.login(loginViewModel)
        sceneCoordinator.transition(to: loginScreen, type: .root)

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
        tokenObservable.accept(token)
    }
}
