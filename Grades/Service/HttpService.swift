//
//  HttpService.swift
//  Grades
//
//  Created by Jiří Zdvomka on 09/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import Foundation
import OAuthSwift
import RxSwift

protocol HasHttpService {
    var httpService: HttpServiceProtocol { get }
}

protocol HttpServiceProtocol {
    typealias HttpMethod = OAuthSwiftHTTPRequest.Method
    typealias HttpParameters = OAuthSwift.Parameters

    @discardableResult
    func get<T: Decodable>(url: URL, parameters: HttpParameters?, headers: [String: String]?) -> Observable<T>

    @discardableResult
    func get(url: URL, parameters: HttpParameters?) -> Observable<String>

    @discardableResult
    func post<T: Encodable>(url: URL, parameters: HttpParameters?, body: T) -> Observable<Void>

    @discardableResult
    func put<T: Encodable>(url: URL, parameters: HttpParameters?, body: T) -> Observable<Void>

    @discardableResult
    func put(url: URL) -> Observable<Void>

    @discardableResult
    func delete<T: Encodable>(url: URL, parameters: HttpParameters?, body: T) -> Observable<Void>
}

/// RxSwift wrapper around OAuthSwift http client to make requests signed with access token
final class HttpService: NSObject, HttpServiceProtocol {
    typealias Dependencies = HasAuthenticationService

    struct Empty: Encodable {}

    private let dependencies: Dependencies
    private let client: AuthClientProtocol
    private let defaultHeaders: Dictionary = [
        "Content-Type": "application/json;charset=UTF-8"
    ]
    private let bag = DisposeBag()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        client = dependencies.authService.client
    }

    /// Make HTTP GET request and return Observable of given type that emits request reuslt
    func get<T>(url: URL, parameters: HttpParameters? = nil, headers: [String: String]? = nil) -> Observable<T> where T: Decodable {
        return request(url, method: .GET, parameters: parameters, headers: headers ?? defaultHeaders)
    }

    var i = 0

    /// Make HTTP GET request and return Observable string
    func get(url: URL, parameters: HttpParameters? = nil) -> Observable<String> {
        let request = Observable<String>.create { [weak self] observer in
            _ = self?.client.request(url, method: .GET,
                                     parameters: parameters ?? [:],
                                     headers: self?.defaultHeaders ?? [:],
                                     body: nil) { result in
                switch result {
                case let .success(response):
                    let data = response.data
                    let decodedResponse = String(decoding: data, as: UTF8.self)

                    observer.onNext(decodedResponse)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }

        return request.retryWhen { [weak self] events in
            events.enumerated().flatMap { [weak self] (attempt, error) -> Observable<Void> in
                if attempt > 2 {
                    return Observable.error(error)
                }
                return self?.handleError(error) ?? Observable.empty()
            }
        }
    }

    /// Make HTTP POST request
    func post<T>(url: URL, parameters: HttpParameters?, body: T) -> Observable<Void> where T: Encodable {
        return request(url, method: .POST, parameters: parameters, headers: defaultHeaders, body: body)
    }

    /// Make HTTP PUT request
    func put<T>(url: URL, parameters: HttpParameters? = nil, body: T) -> Observable<Void> where T: Encodable {
        var headers = defaultHeaders

        if let parameters = parameters {
            for (key, value) in parameters {
                headers[key] = "\(value)"
            }
        }

        return request(url, method: .PUT, parameters: nil, headers: headers, body: body)
    }

    func put(url: URL) -> Observable<Void> {
        return request(url, method: .PUT, body: Empty())
    }

    /// Make HTTP DELETE request
    func delete<T>(url: URL, parameters: HttpParameters?, body: T) -> Observable<Void> where T: Encodable {
        return request(url, method: .DELETE, parameters: parameters, headers: defaultHeaders, body: body)
    }

    // MARK: Helper methods

    /// Reactive wrapper for OAuthSwift reqeust with generic Decodable return type
    private func request<T>(
        _ url: URLConvertible,
        method: HttpMethod,
        parameters: HttpParameters? = nil,
        headers: OAuthSwift.Headers? = nil
    ) -> Observable<T> where T: Decodable {
        let request = Observable<T>.create { [weak self] observer in
            _ = self?.client.request(url, method: method, parameters: parameters ?? [:], headers: headers, body: nil) { result in
                switch result {
                case let .success(response):
                    let data = response.data

                    do {
                        let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                        observer.onNext(decodedResponse)
                        observer.onCompleted()
                    } catch {
                        Log.error("HttpService.request: Could not proccess response data to JSON.\n\(error)\n")
                        observer.onError(ApiError.unprocessableData)
                    }

                case let .failure(error):
                    observer.onError(error)
                }
            }

            return Disposables.create()
        }

        // If error is returned, check access token validity and if invalid refresh, otherwise propagate the error
        return request.retryWhen { [weak self] events in
            events.enumerated().flatMap { [weak self] (attempt, error) -> Observable<Void> in
                if attempt > 2 {
                    return Observable.error(error)
                }
                return self?.handleError(error) ?? Observable.empty()
            }
        }
    }

    /// Reactive wrapper for OAuthSwift reqeust with Codable data and returns no response (Void)
    private func request<T>(
        _ url: URLConvertible,
        method: HttpMethod,
        parameters: HttpParameters? = nil,
        headers: OAuthSwift.Headers? = nil,
        body: T
    ) -> Observable<Void> where T: Encodable {
        let request = Observable<Void>.create { [weak self] observer in
            var data: Data?

            do {
                data = try JSONEncoder().encode(body)
            } catch {
                Log.error("HttpService.request: Could not encode data to JSON: \(error)")
                observer.onError(ApiError.unprocessableData)
            }

            _ = self?.client.request(url, method: method, parameters: parameters ?? [:], headers: headers, body: data) { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()

                case let .failure(error):
                    observer.onError(error)
                }
            }

            return Disposables.create()
        }

        // If error is returned, check access token validity and if invalid refresh, otherwise propagate the error
        return request.retryWhen { [weak self] events in
            events.enumerated().flatMap { [weak self] (attempt, error) -> Observable<Void> in
                if attempt > 2 {
                    return Observable.error(error)
                }
                return self?.handleError(error) ?? Observable.empty()
            }
        }
    }

    /**
     Handle error by http request
     Renew access token when expired
     */
    private func handleError(_ error: Error) -> Observable<Void> {
        if case OAuthSwiftError.tokenExpired = error {
            return Observable.create { [weak self] observer in
                if let self = self {
                    self.dependencies.authService.renewAccessToken.execute()
                        .subscribe(
                            onError: { error in
                                if case ActionError.notEnabled = error {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        observer.onNext(())
                                        observer.onCompleted()
                                    }
                                } else {
                                    Log.error("HttpService.request: Error refreshing token: \(error.localizedDescription)")
                                    observer.onError(error)
                                }
                            }, onCompleted: {
                                observer.onNext(())
                                observer.onCompleted()
                            }
                        )
                        .disposed(by: self.bag)
                }

                return Disposables.create()
            }
        } else if case is OAuthSwiftError = error {
            Log.error("HttpService.request: OAuthSwiftError: \(error)")
            // swiftlint:disable force_cast
            return Observable.error(ApiError.getError(forCode: (error as! OAuthSwiftError).errorCode))
        } else {
            Log.error("HttpService.request: General API error: \(error)")
            return Observable.error(error)
        }
    }
}
