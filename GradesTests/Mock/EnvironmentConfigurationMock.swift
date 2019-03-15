//
//  EnvironmentConfigurationMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 09/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

@testable import GradesDev

struct EnvironmentConfigurationMock: NSClassificationConfiguration {
	
	var auth: Auth {
		return Auth()
	}
	
	var gradesAPI: [String: String] = [:]
	var kosAPI: [String : String] = [:]
}
