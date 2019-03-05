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
    static func getUser() -> Observable<User>
    static func getRoles() -> Observable<UserRoles>
    static func getCourses() -> Observable<[Course]>
}

class GradesAPI: GradesAPIProtocol {
    private static let config = EnvironmentConfiguration.shared.gradesAPI

    // MARK: API endpoints

    private enum Endpoint {
        case userInfo
        case roles
        case students

        // swiftlint:disable force_cast
        private static let baseURL = config["BaseURL"]

        var value: String {
            switch self {
            case .userInfo:
                return Endpoint.createURL(config["UserInfo"])
            case .roles:
                return Endpoint.createURL(config["Roles"])
            case .students:
                return Endpoint.createURL((config["Students"] as! String).replacingOccurrences(of: ":username", with: "zdvomjir")) // TODO: generic parameter replacement
            }
        }

        private static func createURL(_ endpoint: Any?) -> String {
            return "\(baseURL as! String)\(endpoint as! String)"
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

    /// Fetch user info and roles
    static func getUser() -> Observable<User> {
        let userInfoObservable: Observable<UserInfo> = request(endpoint: Endpoint.userInfo, method: HTTPMethod.get)
        let rolesObservable = getRoles() // TODO: roles at User might not be needed

        return Observable<User>.zip(userInfoObservable, rolesObservable) { User(info: $0, roles: $1) }
    }

    static func getRoles() -> Observable<UserRoles> {
        return request(endpoint: Endpoint.roles, method: HTTPMethod.get)
    }

    /// Fetch subjects
    static func getCourses() -> Observable<[Course]> {
        return request(endpoint: .students, method: .get) // TODO: add lang and semestr parameters
    }

    // MARK: Support methods

    private static func request<T: Codable>(endpoint: Endpoint,
                                            method: HTTPMethod,
                                            parameters: Parameters? = nil) -> Observable<T> {
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
