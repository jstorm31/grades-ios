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

enum AuthenticationError: Error {
    case generic
}

extension AuthenticationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .generic:
            return L10n.Error.Auth.generic
        }
    }
}

class AuthenticationService {
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
    func authenticate(useBuiltInSafari: Bool = true, viewController: ViewController? = nil) -> Observable<Void> {
        if useBuiltInSafari, let viewController = viewController {
            handler.authorizeURLHandler = SafariURLHandler(viewController: viewController, oauthSwift: handler)
        }

        return Observable<Void>.create { [weak self] (observer: AnyObserver<Void>) -> Disposable in
            guard let `self` = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            let handle = self.handler.authorize(withCallbackURL: self.callbackUrl,
                                                scope: self.scope,
                                                state: "",
                                                headers: ["Authorization": self.authorizationHeader],
                                                success: { _, _, _ in
                                                    observer.onCompleted()
                                                }, failure: { error in
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
        }.share()
    }
}
