//
//  EnvironmentConfiguration.swift
//  Classification
//
//  Created by Jiří Zdvomka on 25/02/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

// taken from https://benscheirman.com/2018/10/xcode-environment-specific-configuration/

import Foundation

final class EnvironmentConfiguration {
	private let config: NSDictionary

	init(dictionary: NSDictionary) {
		config = dictionary
	}

	convenience init() {
		let bundle = Bundle.main
		let configPath = bundle.path(forResource: "config", ofType: "plist")!
		let config = NSDictionary(contentsOfFile: configPath)!

		let dict = NSMutableDictionary()
		if let commonConfig = config["Common"] as? [AnyHashable: Any] {
			dict.addEntries(from: commonConfig)
		}

		if let environment = bundle.infoDictionary!["ConfigEnvironment"] as? String {
			if let environmentConfig = config[environment] as? [AnyHashable: Any] {
				dict.addEntries(from: environmentConfig)
			}
		}

		self.init(dictionary: dict)
	}
}

protocol NSClassificationConfiguration {
	var authServerUrl: String { get }
}

// swiftlint:disable force_cast
// Note: for debugging it is better for the app to crash if corresponding key
//       is missing rather than providing default value
extension EnvironmentConfiguration: NSClassificationConfiguration {
	var authServerUrl: String {
		return config["AuthServerUrl"] as! String
	}
}
