//
//  AuthenticationServiceProtocol.swift
//  Grades
//
//  Created by Jiří Zdvomka on 01/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import OAuthSwift

enum AuthenticationError: Error {
}

class Authentication {
	
	// MARK: properties
	
	private let handler: OAuth2Swift
	private let callbackUrl: URL
	private let authorizationHeader: String
	private let scope: String
	
	
	// MARK: initializers
	
	init(configuration: NSClassificationConfiguration) {
		callbackUrl = URL(string: configuration.auth.redirectUri)!
		authorizationHeader = "Basic \(configuration.auth.clientHash)"
		scope = configuration.auth.scope
		
		handler = OAuth2Swift(consumerKey: configuration.auth.clientId,
									 consumerSecret: configuration.auth.clientSecret,
									 authorizeUrl: configuration.auth.authorizeUrl,
									 accessTokenUrl: configuration.auth.tokenUrl,
									 responseType: configuration.auth.responseType)
		handler.allowMissingStateCheck = true
	}
	
	convenience init() {
		self.init(configuration: EnvironmentConfiguration.shared)
	}
	
	
	// MARK: public methods
	
	/// Authenticate with CTU OAuth2.0 server
	func authenticate(useBuiltInSafari: Bool = true, viewController: ViewController? = nil) {
		if useBuiltInSafari, let viewController = viewController {
			handler.authorizeURLHandler = SafariURLHandler(viewController: viewController, oauthSwift: handler)
		}
		
		handler.authorize(withCallbackURL: callbackUrl,
								scope: scope,
								state: "",
								headers: ["Authorization": authorizationHeader],
								success: { credential, response, parameters in
			print("Successfuly authenticated!")
			
		}, failure: { error in
			print("Authentication failed")
			print(error.underlyingMessage)
			print(error.underlyingError)
			print(error.localizedDescription)
			print(error)
		})
	}
	
}
