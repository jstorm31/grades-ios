//
//  AuthClient.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 24/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import OAuthSwift

/// Wrapper around OAuthSwiftClient to make it testable
protocol AuthClientProtocol {
    var credential: OAuthSwiftCredential { get }

    func request(_ url: URLConvertible, method: OAuthSwiftHTTPRequest.Method, parameters: OAuthSwift.Parameters,
                 headers: OAuthSwift.Headers?, body: Data?, success: OAuthSwiftHTTPRequest.SuccessHandler?,
                 failure: OAuthSwiftHTTPRequest.FailureHandler?) -> OAuthSwiftRequestHandle?
}

final class AuthClient: AuthClientProtocol {
    var credential: OAuthSwiftCredential

    private let client: OAuthSwiftClient

    init(client: OAuthSwiftClient) {
        self.client = client
        credential = client.credential
    }

    @discardableResult
    func request(_ url: URLConvertible, method: OAuthSwiftHTTPRequest.Method, parameters: OAuthSwift.Parameters = [:],
                 headers: OAuthSwift.Headers? = nil, body: Data? = nil, success: OAuthSwiftHTTPRequest.SuccessHandler?,
                 failure: OAuthSwiftHTTPRequest.FailureHandler?) -> OAuthSwiftRequestHandle? {
        return client.request(url, method: method, parameters: parameters, headers: headers, body: body, success: success, failure: failure)
    }
}
