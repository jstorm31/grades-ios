//
//  AppDelegate.swift
//  Classification
//
//  Created by Jiří Zdvomka on 25/02/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Alamofire
import OAuthSwift
import OAuthSwiftAlamofire
import UIKit

import Bagel // TODO: remove on release

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private let config: NSClassificationConfiguration = EnvironmentConfiguration.shared

    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = LoginViewController()

        Bagel.start() // TODO: remove on release

        // Connect Alamofire and OAuthSwift
        let sessionManager = SessionManager.default
        sessionManager.adapter = OAuthSwiftRequestAdapter(AuthenticationService.shared.handler)

        // Scene coordinator
        let sceneCoordinator = SceneCoordinator(window: window!)
        let loginViewModel = LoginViewModel(sceneCoordinator: sceneCoordinator)
        let loginScreen = Scene.login(loginViewModel)
        sceneCoordinator.transition(to: loginScreen, type: .root)

        return true
    }

    func application(_: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let sourceApp = options[.sourceApplication] as? String
        let isOpenedBySafari = sourceApp == "com.apple.SafariViewService" || sourceApp == "com.apple.mobilesafari"

        if isOpenedBySafari, url.host == config.auth.callbackId {
            OAuthSwift.handle(url: url)
        }

        return true
    }
}
