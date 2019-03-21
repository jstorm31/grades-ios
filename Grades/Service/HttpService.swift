//
//  HttpService.swift
//  Grades
//
//  Created by Jiří Zdvomka on 09/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import OAuthSwift
import RxSwift

/// RxSwift wrapper around OAuthSwift http client to make requests signed with access token
protocol HttpServiceProtocol {
    typealias HttpMethod = OAuthSwiftHTTPRequest.Method
    typealias HttpParameters = OAuthSwift.Parameters

    @discardableResult
    func get<T: Decodable>(url: URL, parameters: HttpParameters?) -> Observable<T>
    func get(url: URL, parameters: HttpParameters?) -> Observable<String>
}

class HttpService: NSObject, HttpServiceProtocol {
    private let client: OAuthSwiftClient

    init(client: OAuthSwiftClient) {
        self.client = client
    }

    /// Make HTTP GET request and return Observable of given type that emits request reuslt
    func get<T>(url: URL, parameters: HttpParameters? = nil) -> Observable<T> where T: Decodable {
        return Observable.create { [weak self] observer in
            self?.client.request(url, method: .GET, parameters: parameters ?? [:], success: { response in
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
                Log.error("HttpService.request: External API error: \(error.localizedDescription)")
                observer.onError(ApiError.getError(forCode: error.errorCode))
            })

            return Disposables.create()
        }
    }

    /// Make HTTP GET request and return Observable string
    func get(url: URL, parameters: HttpParameters? = nil) -> Observable<String> {
        return Observable.create { [weak self] observer in
            self?.client.request(url, method: .GET, parameters: parameters ?? [:], success: { response in
                let data = response.data

                let decodedResponse = String(decoding: data, as: UTF8.self)
                observer.onNext(decodedResponse)
                observer.onCompleted()
            }, failure: { error in
                Log.error("HttpService.request: External API error: \(error.localizedDescription)")
                observer.onError(ApiError.getError(forCode: error.errorCode))
            })

            return Disposables.create()
        }
    }
}
