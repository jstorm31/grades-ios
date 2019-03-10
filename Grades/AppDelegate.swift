//
//  AppDelegate.swift
//  Classification
//
//  Created by Jiří Zdvomka on 25/02/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import OAuthSwift
import UIKit

import Bagel // TODO: remove on release

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private let config = EnvironmentConfiguration()

    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = LoginViewController()

        Bagel.start() // TODO: remove on release

        // LoginViewModel dependencies initialization
        let sceneCoordinator = SceneCoordinator(window: window!)
        let authService = AuthenticationService(configuration: config)
        let httpService = HttpService(client: authService.handler.client)
        let gradesApi = GradesAPI(httpService: httpService, configuration: config)

        let loginViewModel = LoginViewModel(sceneCoordinator: sceneCoordinator,
                                            configuration: config,
                                            authenticationService: authService,
                                            httpService: httpService,
                                            gradesApi: gradesApi)
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
