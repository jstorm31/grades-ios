//
//  EnvironmentConfigurationMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 09/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

@testable import GradesDev

struct EnvironmentConfigurationMock: NSClassificationConfiguration {
	var defaultLanguage = "en"
	
	var auth: Auth {
		return Auth()
	}
	
	var notificationServerUrl: String {
		return "http://testNotificationUrl.com"
	}
	
	var gradesAPI: [String: String] = [:]
	
	var keychain = KeychainCredentials(serviceName: "test", accessGroup: "test")
}
