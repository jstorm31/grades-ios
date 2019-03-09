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
    static let shared = AuthenticationService()

    let handler: OAuth2Swift
    private let callbackUrl: URL
    private let authorizationHeader: String
    private let scope: String
    private let bag = DisposeBag()

    var user: UserInfo?

    // MARK: initializers

    private init(configuration: NSClassificationConfiguration) {
        let configuration = EnvironmentConfiguration.shared
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

    private convenience init() {
        self.init(configuration: EnvironmentConfiguration.shared)
    }

    // MARK: public methods

    /// Authenticate with CTU OAuth2.0 server
    func authenticate(useBuiltInSafari: Bool = true, viewController: UIViewController? = nil) -> Observable<Void> {
        // TODDO: implement isLoading
        if useBuiltInSafari, let viewController = viewController {
            handler.authorizeURLHandler = SafariURLHandler(viewController: viewController, oauthSwift: handler)
        }

        return Observable<Void>.create { [weak self] (observer: AnyObserver<Void>) -> Disposable in
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
                               // Get user info
                               GradesAPI.shared.getUser()
                                   .subscribe(onNext: { [weak self] user in
                                       Log.debug(user.username)
                                       self?.user = user
                                       observer.onCompleted()
                                   })
                                   .disposed(by: self.bag)
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
        }
    }
}
