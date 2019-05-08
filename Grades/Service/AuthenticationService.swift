//
//  AuthenticationServiceProtocol.swift
//  Grades
//
//  Created by Jiří Zdvomka on 01/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import Foundation
import OAuthSwift
import RxSwift
import SwiftKeychainWrapper

protocol HasAuthenticationService {
    var authService: AuthenticationServiceProtocol { get }
}

protocol AuthenticationServiceProtocol {
    var handler: OAuth2Swift { get }
    var client: AuthClientProtocol { get }
    var renewAccessToken: CocoaAction { get }

    func authenticate(useBuiltInSafari: Bool, viewController: UIViewController?) -> Observable<Bool>
    func authenticateWitRefreshToken() -> Observable<Bool>
    func logOut()
}

final class AuthenticationService: AuthenticationServiceProtocol {
    let handler: OAuth2Swift
    let client: AuthClientProtocol
    private let callbackUrl: URL
    private let authorizationHeader: String
    private let scope: String
    private let bag = DisposeBag()
    private let config: EnvironmentConfiguration

    // MARK: initializers

    init() {
        config = EnvironmentConfiguration.shared

        callbackUrl = URL(string: config.auth.redirectUri)!
        authorizationHeader = "Basic \(config.auth.clientHash)"
        scope = config.auth.scope

        handler = OAuth2Swift(consumerKey: config.auth.clientId,
                              consumerSecret: config.auth.clientSecret,
                              authorizeUrl: config.auth.authorizeUrl,
                              accessTokenUrl: config.auth.tokenUrl,
                              responseType: config.auth.responseType)
        handler.allowMissingStateCheck = true
        client = AuthClient(client: handler.client)
    }

    // MARK: public methods

    /// Authenticate with CTU OAuth2.0 server
    func authenticate(useBuiltInSafari: Bool = true, viewController: UIViewController? = nil) -> Observable<Bool> {
        if CommandLine.arguments.contains("--stub-authentication") {
            return Observable.just(true)
        }

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
                           success: { [weak self] _, _, _ in
                               self?.saveCredentialsInKeychain()
                               observer.onNext(true)
                               observer.onCompleted()
                           }, failure: { error in
                               Log.error("AuthenticationService.authenticate: Authentication error. \(error.localizedDescription)")
                               #if DEBUG
                                   observer.onError(error)
                               #endif
                               observer.onError(AuthenticationError.generic)
                })

            return Disposables.create {
                handle?.cancel()
            }
        }
    }

    /// Try to load refresh token from Keychain and obtain new access token
    func authenticateWitRefreshToken() -> Observable<Bool> {
        loadCredentialsFromKeychain()

        if handler.client.credential.oauthRefreshToken.isEmpty {
            return Observable.just(false)
        }
        return renewAccessToken.execute().map { _ in true }
    }

    func logOut() {
        removeCredentialsFromKeychain()
    }

    /// Renew access token with refresh token
    lazy var renewAccessToken = CocoaAction { [weak self] in
        Observable.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }
            let credential = self.handler.client.credential

            // Build request
            var request = URLRequest(url: URL(string: self.config.auth.tokenUrl)!)
            request.httpMethod = "POST"
            request.setValue(self.authorizationHeader, forHTTPHeaderField: "Authorization")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let body = "grant_type=refresh_token&refresh_token=\(credential.oauthRefreshToken)"
            request.httpBody = body.data(using: .utf8)

            // Make request
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                if let error = error {
                    Log.error("AuthenticationService:renewAccessToken: \(error)")
                    observer.onError(error)
                } else {
                    if let data = data {
                        do {
                            let tokenResponse = try JSONDecoder().decode(AuthTokenResponse.self, from: data)

                            // Set new tokens
                            credential.oauthToken = tokenResponse.accessToken.safeStringByRemovingPercentEncoding
                            credential.oauthRefreshToken = tokenResponse.refreshToken.safeStringByRemovingPercentEncoding
                            credential.oauthTokenExpiresAt = Date(timeInterval: tokenResponse.expiresIn, since: Date())
                            self?.saveCredentialsInKeychain()

                            observer.onNext(())
                            observer.onCompleted()
                        } catch {
                            observer.onError(ApiError.unprocessableData)
                        }
                    }
                }
            }
            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }

    /// Save Auth credentials in keychain
    private func saveCredentialsInKeychain() {
        KeychainWrapper.standard.set(handler.client.credential.oauthRefreshToken,
                                     forKey: "refreshToken",
                                     withAccessibility: .afterFirstUnlock)
    }

    private func loadCredentialsFromKeychain() {
        if let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken") {
            handler.client.credential.oauthRefreshToken = refreshToken
        }
    }

    private func removeCredentialsFromKeychain() {
        KeychainWrapper.standard.removeObject(forKey: "refreshToken")
    }
}
