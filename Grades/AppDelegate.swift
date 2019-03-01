//
//  AppDelegate.swift
//  Classification
//
//  Created by Jiří Zdvomka on 25/02/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	private let config: NSClassificationConfiguration = EnvironmentConfiguration.shared
	
	// swiftlint:disable vertical_parameter_alignment
	func application(_ application: UIApplication,
						  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}
	
	// swiftlint:disable identifier_name
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		let sourceApp = options[.sourceApplication] as? String
		let isOpenedBySafari = sourceApp == "com.apple.SafariViewService" || sourceApp == "com.apple.mobilesafari"
		
		if isOpenedBySafari && url.host == config.auth.callbackId {
			OAuthSwift.handle(url: url)
		}
		
		return true
	}
	
}
