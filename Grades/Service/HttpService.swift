//
//  HttpService.swift
//  Grades
//
//  Created by Jiří Zdvomka on 09/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import OAuthSwift
import RxSwift

protocol HasHttpService {
    var httpService: HttpServiceProtocol { get }
}

protocol HttpServiceProtocol {
    typealias HttpMethod = OAuthSwiftHTTPRequest.Method
    typealias HttpParameters = OAuthSwift.Parameters

    @discardableResult
    func get<T: Decodable>(url: URL, parameters: HttpParameters?) -> Observable<T>

    @discardableResult
    func get(url: URL, parameters: HttpParameters?) -> Observable<String>

    @discardableResult
    func put<T: Encodable>(url: URL, parameters: HttpParameters?, body: T) -> Observable<Void>
}

/// RxSwift wrapper around OAuthSwift http client to make requests signed with access token
final class HttpService: NSObject, HttpServiceProtocol {
    typealias Dependencies = HasAuthenticationService

    private let dependencies: Dependencies
    private let client: OAuthSwiftClient
    private let defaultHeaders = [
        "Content-Type": "application/json;charset=UTF-8"
    ]
    private let bag = DisposeBag()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        client = dependencies.authService.handler.client
    }

    /// Make HTTP GET request and return Observable of given type that emits request reuslt
    func get<T>(url: URL, parameters: HttpParameters? = nil) -> Observable<T> where T: Decodable {
		return request(url, method: .GET, parameters: parameters ?? [:], headers: defaultHeaders, body: nil)
    }

    /// Make HTTP GET request and return Observable string
    func get(url: URL, parameters: HttpParameters? = nil) -> Observable<String> {
        return Observable.create { [weak self] observer in
            self?.client.request(
                url,
                method: .GET,
                parameters: parameters ?? [:],
                headers: self?.defaultHeaders ?? [:],
                success: { response in
                    let data = response.data

                    let decodedResponse = String(decoding: data, as: UTF8.self)
                    observer.onNext(decodedResponse)
                    observer.onCompleted()
                }, failure: { error in
                    self?.handleError(error)
                    observer.onError(ApiError.getError(forCode: error.errorCode))
                }
            )
            return Disposables.create()
        }
    }

    /// Make HTTP PUT request
    func put<T>(url: URL, parameters: HttpParameters?, body: T) -> Observable<Void> where T: Encodable {
        return Observable.create { [weak self] observer in
            var data: Data!

            do {
                data = try JSONEncoder().encode(body)
            } catch {
                Log.error("HttpService.request: Could not encode data to JSON.\n\(error)\n")
                observer.onError(ApiError.unprocessableData)
            }

            self?.client.request(
                url,
                method: .PUT,
                parameters: parameters ?? [:],
                headers: self?.defaultHeaders ?? [:],
                body: data,
                success: { _ in
                    observer.onNext(())
                    observer.onCompleted()
                }, failure: { [weak self] error in
                    self?.handleError(error)
                    observer.onError(ApiError.getError(forCode: error.errorCode))
                }
            )

            return Disposables.create()
        }
    }

    // MARK: Helper methods

    /// Reactive wrapper for OAuthSwift reqeust
    private func request<T>(
        _ url: URLConvertible,
        method: OAuthSwiftHTTPRequest.Method,
        parameters: OAuthSwift.Parameters = [:],
        headers: OAuthSwift.Headers? = nil,
        body _: Data? = nil
    ) -> Observable<T> where T: Decodable {
        let request = Observable<T>.create { [weak self] observer in
            self?.client.request(
                url,
                method: method,
                parameters: parameters,
                headers: headers,
                success: { response in
                    let data = response.data

                    do {
                        let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                        observer.onNext(decodedResponse)
                        observer.onCompleted()
                    } catch {
                        Log.error("HttpService.request: Could not proccess response data to JSON.\n\(error)\n")
                        observer.onError(ApiError.unprocessableData)
                    }
                }, failure: { error in
                    observer.onError(ApiError.getError(forCode: error.errorCode))
                }
            )

            return Disposables.create()
        }

        return request.retryWhen { [weak self] events in
            events.enumerated().flatMap { [weak self] (_, error) -> Observable<Void> in
                self?.handleError(error) ?? Observable.empty()
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
                if let `self` = self {
                    self.dependencies.authService.renewAccessToken.execute()
                        .subscribe(
                            onError: { error in
                                Log.error("HttpService.request: Error refreshing token: \(error.localizedDescription)")
                                observer.onError(error)
                            }, onCompleted: {
                                observer.onNext(())
                                observer.onCompleted()
                            }
                        )
                        .disposed(by: self.bag)
                }

                return Disposables.create()
            }
        } else {
            Log.error("HttpService.request: External API error: \(error.localizedDescription)")
            return Observable.error(error)
        }
    }
}
