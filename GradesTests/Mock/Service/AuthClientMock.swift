//
//  AuthClient.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 24/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import OAuthSwift
@testable import Grades

enum AuthClientResult {
	case success, failure, expires
}

final class AuthClientMock: AuthClientProtocol {
	var result = AuthClientResult.success
	var called = 0;
	var credential = OAuthSwiftCredential(consumerKey: "asdf", consumerSecret: "asdf")
	
    func request(_ url: URLConvertible, method: OAuthSwiftHTTPRequest.Method, parameters: OAuthSwift.Parameters = [:],
                 headers: OAuthSwift.Headers? = nil, body: Data? = nil, completionHandler: OAuthSwiftHTTPRequest.CompletionHandler?) -> OAuthSwiftRequestHandle? {
		if called > 0 {
			result = .success
		}
		called += 1
		
		switch result {
		case .success:
			let data = Data(base64Encoded: "dGVzdA==")!
			let response = HTTPURLResponse(url: URL(string: "http://google.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
            
            completionHandler?(.success(.init(data: data, response: response, request: nil)))
		case .failure:
            completionHandler?(.failure(OAuthSwiftError.encodingError(urlString: url.string)))
		case .expires:
            completionHandler?(.failure(OAuthSwiftError.tokenExpired(error: nil)))
		}
		
		return nil
	}
}
