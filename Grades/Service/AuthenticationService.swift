//
//  AuthenticationServiceProtocol.swift
//  Grades
//
//  Created by Jiří Zdvomka on 01/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import OAuthSwift
import RxSwift

protocol AuthenticationServiceProtocol {
    var handler: OAuth2Swift { get }

    func authenticate(useBuiltInSafari: Bool, viewController: UIViewController?) -> Observable<Bool>
}

class AuthenticationService: AuthenticationServiceProtocol {
    var handler: OAuth2Swift
    private let callbackUrl: URL
    private let authorizationHeader: String
    private let scope: String
    private let bag = DisposeBag()

    // MARK: initializers

    init() {
        let config = EnvironmentConfiguration.shared

        callbackUrl = URL(string: config.auth.redirectUri)!
        authorizationHeader = "Basic \(config.auth.clientHash)"
        scope = config.auth.scope

        handler = OAuth2Swift(consumerKey: config.auth.clientId,
                              consumerSecret: config.auth.clientSecret,
                              authorizeUrl: config.auth.authorizeUrl,
                              accessTokenUrl: config.auth.tokenUrl,
                              responseType: config.auth.responseType)
        handler.allowMissingStateCheck = true
    }

    // MARK: public methods

    /// Authenticate with CTU OAuth2.0 server
    func authenticate(useBuiltInSafari: Bool = true, viewController: UIViewController? = nil) -> Observable<Bool> {
        if useBuiltInSafari, let viewController = viewController {
            handler.authorizeURLHandler = SafariURLHandler(viewController: viewController, oauthSwift: handler)
        }

        return Observable.create { [weak self] observer in
            guard let `self` = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            // Authorize
            let handle = self.handler
                .authorize(withCallbackURL: self.callbackUrl,
                           scope: self.scope,
                           state: "",
                           headers: ["Authorization": self.authorizationHeader],
                           success: { _, _, _ in
                               observer.onNext(true)
                               observer.onCompleted()
                           }, failure: { error in
                               Log.error("AuthenticationService.authenticate: Authentication error.")
                               #if DEBUG
                                   observer.onError(error)
                               #endif
                               observer.onError(
                                   AuthenticationError.generic
                               )
                })

            return Disposables.create {
                handle?.cancel()
            }
        }
    }
}
