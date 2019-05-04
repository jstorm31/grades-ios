//
//  AuthClient.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 24/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import OAuthSwift
@testable import GradesDev

enum AuthClientResult {
	case success, failure, expires
}

final class AuthClientMock: AuthClientProtocol {
	var result = AuthClientResult.success
	private var called = 0;
	
	func request(_ url: URLConvertible, method: OAuthSwiftHTTPRequest.Method, parameters: OAuthSwift.Parameters = [:],
				 headers: OAuthSwift.Headers? = nil, body: Data? = nil, success: OAuthSwiftHTTPRequest.SuccessHandler?,
				 failure: OAuthSwiftHTTPRequest.FailureHandler?) -> OAuthSwiftRequestHandle? {
		if called > 0 {
			result = .success
		}
		called += 1
		
		switch result {
		case .success:
			let data = Data(base64Encoded: "a")!
			let response = HTTPURLResponse(url: URL(string: "http://google.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
			success?(OAuthSwiftResponse(data: data, response: response, request: nil))
		case .failure:
			failure?(OAuthSwiftError.encodingError(urlString: url.string))
		case .expires:
			failure?(OAuthSwiftError.tokenExpired(error: nil))
		}
		
		return nil
	}
}
