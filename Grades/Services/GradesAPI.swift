//
//  GradesAPI.swift
//  Grades
//
//  Created by Jiří Zdvomka on 03/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Alamofire
import Foundation
import RxCocoa
import RxSwift

typealias JSONObject = [String: Any]

protocol GradesAPIProtocol {
    static func subjects() -> Observable<[Subject]>
}

class GradesAPI: GradesAPIProtocol {
    private static let config = EnvironmentConfiguration.shared.gradesAPI

    // MARK: API endpoints

    private enum Endpoint {
        case students

        // swiftlint:disable force_cast
        private static let baseURL = config["BaseURL"] as! String

        var value: String {
            switch self {
            case .students:
                return Endpoint.createURL((config["Students"] as! String).replacingOccurrences(of: ":username", with: "zdvomjir")) // TODO: generic parameter replacement
            }
        }

        private static func createURL(_ endpoint: String) -> String {
            return "\(baseURL)\(endpoint)"
        }
    }

    // MARK: API errors

    enum Errors: Int, Error {
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
        case unprocessableData
    }

    // MARK: Endpoint requests

    static func subjects() -> Observable<[Subject]> {
        return request(endpoint: .students, method: .get, parameters: nil) // TODO: add lang and semestr parameters
    }

    // MARK: Support methods

    private static func request<T: Codable>(endpoint: Endpoint,
                                            method: HTTPMethod,
                                            parameters: Parameters?) -> Observable<T> {
        return Observable.create { observer in
            let request = Alamofire.request(endpoint.value,
                                            method: method,
                                            parameters: parameters,
                                            encoding: URLEncoding.httpBody,
                                            headers: nil)

            request.validate().responseData { response in
                switch response.result {
                case .success:
                    if let data = response.result.value {
                        do {
                            let decoded = try JSONDecoder().decode(T.self, from: data)
                            observer.onNext(decoded)
                            observer.onCompleted()
                        } catch {
                            print(error)
                            observer.onError(Errors.unprocessableData)
                        }
                    } else {
                        observer.onError(Errors.unprocessableData)
                    }
                case let .failure(error):
                    observer.onError(error) // TODO: map to custom errors
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}
