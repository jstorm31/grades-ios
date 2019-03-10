//
//  AuthenticationServiceMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 09/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import OAuthSwift
@testable import GradesDev

class AuthenticationServiceMock: AuthenticationServiceProtocol {
	let handler: OAuth2Swift
	var result: MockResult = .success
	
	enum MockResult {
		case success
		case failure
	}
	
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
}
