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
    func getUser() -> Observable<UserInfo>
    func getRoles() -> Observable<UserRoles>
    func getCourses() -> Observable<[Course]>
}

class GradesAPI: GradesAPIProtocol {
    static let shared = GradesAPI() // TODO: replace with dependenci injection
    private static let config = EnvironmentConfiguration.shared.gradesAPI

    private init() {}

    // MARK: API endpoints

    private enum Endpoint {
        case userInfo
        case roles
        case courses(String)

        // swiftlint:disable force_cast
        private static let baseURL = config["BaseURL"]

        var value: String {
            switch self {
            case .userInfo:
                return Endpoint.createURL(config["UserInfo"])
            case .roles:
                return Endpoint.createURL(config["Roles"])
            case let .courses(username):
                let url = (config["Courses"] as! String).replacingOccurrences(of: ":username", with: username)
                return Endpoint.createURL(url)
            }
        }

        private static func createURL(_ endpoint: Any?) -> String {
            return "\(baseURL as! String)\(endpoint as! String)"
        }
    }

    // MARK: Endpoint requests

    /// Fetch user info and roles
    func getUser() -> Observable<UserInfo> {
        return request(endpoint: Endpoint.userInfo, method: HTTPMethod.get)
    }

    /// Fetch user roles
    func getRoles() -> Observable<UserRoles> {
        return request(endpoint: Endpoint.roles, method: HTTPMethod.get)
    }

    /// Fetch subjects
    func getCourses() -> Observable<[Course]> {
        let username = AuthenticationService.shared.user!.username
        return request(endpoint: .courses(username), method: .get) // TODO: add lang and semestr parameters
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
                        Log.error("GradesAPI.request: Could not proccess response.")
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
