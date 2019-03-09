//
//  GradesAPI.swift
//  Grades
//
//  Created by Jiří Zdvomka on 03/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxSwift

protocol GradesAPIProtocol {
    func getUser() -> Observable<UserInfo>
    func getRoles() -> Observable<UserRoles>
    func getCourses() -> Observable<[Course]>
}

class GradesAPI: GradesAPIProtocol {
    private let config: [String: String]
    private let httpService: HttpServiceProtocol

    private var baseUrl: String {
        return config["BaseURL"]!
    }

    init(httpService: HttpServiceProtocol, configuration: EnvironmentConfiguration) {
        config = configuration.gradesAPI
        self.httpService = httpService
    }

    // MARK: API endpoints

    private enum Endpoint {
        case userInfo
        case roles
        case courses(String)
    }

    // MARK: Endpoint requests

    /// Fetch user info and roles
    func getUser() -> Observable<UserInfo> {
        return httpService.get(url: createURL(from: .userInfo), parameters: nil)
    }

    /// Fetch user roles
    func getRoles() -> Observable<UserRoles> {
        return httpService.get(url: createURL(from: .roles), parameters: nil)
    }

    /// Fetch subjects for current user
    func getCourses() -> Observable<[Course]> {
        return httpService.get(url: createURL(from: .courses("zdvomjir")), parameters: nil)

        // TODO: add lang and semestr parameters
        //		return getUser()
        //			.flatMap { [weak self] user in
        //				guard let `self` = self else {
        //					throw ApiError.general
        //				}
//
        //				return self.httpService
        //					.get(url: (self.createURL(from: .courses(user.username))), parameters: nil)
        //			}
    }

    // MARK: helpers

    private func createURL(from endpoint: Endpoint) -> URL {
        var endpointValue = ""

        switch endpoint {
        case .userInfo:
            endpointValue = config["UserInfo"]!
        case .roles:
            endpointValue = config["Roles"]!
        case let .courses(username):
            endpointValue = config["Courses"]!.replacingOccurrences(of: ":username", with: username)
        }

        return URL(string: "\(baseUrl)\(endpointValue)")!
    }
}
