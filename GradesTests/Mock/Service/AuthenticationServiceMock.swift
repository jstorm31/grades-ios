//
//  AuthenticationServiceMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 09/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit
import RxSwift
import Action
import OAuthSwift
@testable import Grades

extension AuthenticationServiceProtocol {
	
}

class AuthenticationServiceMock: AuthenticationServiceProtocol {
	let handler: OAuth2Swift
	let client: AuthClientProtocol = AuthClientMock()
	var result = Result.success
	
	init() {
		handler = OAuth2Swift(consumerKey: "",
							  consumerSecret: "",
							  authorizeUrl: "",
							  accessTokenUrl: "",
							  responseType: "")
	}
	
	func authenticate(useBuiltInSafari: Bool, viewController: UIViewController?) -> Observable<Bool> {
		switch result {
		case .success:
			return Observable.just(true)
		case .failure:
			return Observable.error(AuthenticationError.generic)
		}
	}
	
	func authenticateWitRefreshToken() -> Observable<Bool> {
		switch result {
		case .success:
			return Observable.just(true)
		case .failure:
			return Observable.error(AuthenticationError.generic)
		}
	}
	
	func logOut() {}
	
	
	var renewAccessToken = CocoaAction {
		return Observable.empty()
	}
}
