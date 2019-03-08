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
    func getUser() -> Observable<User>
    func getRoles() -> Observable<UserRoles>
    func getCourses() -> Observable<[Course]>
}

class GradesAPI: GradesAPIProtocol {
    static let shared = GradesAPI()
    private static let config = EnvironmentConfiguration.shared.gradesAPI

    private init() {}

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

    // MARK: Endpoint requests

    /// Fetch user info and roles
    func getUser() -> Observable<User> {
        let userInfoObservable: Observable<UserInfo> = request(endpoint: Endpoint.userInfo, method: HTTPMethod.get)
        let rolesObservable = getRoles() // TODO: roles at User might not be needed

        return Observable<User>.zip(userInfoObservable, rolesObservable) {
            User(info: $0, roles: $1)
        }
    }

    func getRoles() -> Observable<UserRoles> {
        return request(endpoint: Endpoint.roles, method: HTTPMethod.get)
    }

    /// Fetch subjects
    func getCourses() -> Observable<[Course]> {
        return request(endpoint: .students, method: .get) // TODO: add lang and semestr parameters
    }

    // MARK: Support methods

    private func request<T: Codable>(endpoint: Endpoint,
                                     method: HTTPMethod,
                                     parameters: Parameters? = nil) -> Observable<T> {
        return Observable.create { observer in
            // TODO: consider using native networking
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
                            Log.error("GradesAPI.request: Could not decode external data.")
                            observer.onError(ApiError.undecodableData)
                        }
                    } else {
                        Log.error("GradesAPI.request: Could not proccess response")
                        observer.onError(ApiError.unprocessableData)
                    }
                case let .failure(error):
                    Log.error("GradesAPI.request: External API error: \(error.localizedDescription)")
                    observer.onError(ApiError.getError(forCode: response.response?.statusCode ?? 0))
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}
