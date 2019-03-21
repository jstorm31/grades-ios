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
    var settings: SettingsRepositoryProtocol? { get set }

    func getUser() -> Observable<UserInfo>
    func getRoles() -> Observable<UserRoles>
    func getCourses(username: String) -> Observable<[Course]>
    func getCourse(code: String) -> Observable<CourseDetailRaw>
    func getCourseStudentClassification(username: String, code: String) -> Observable<CourseStudent>
    func getCurrentSemestrCode() -> Observable<String>
}

class GradesAPI: GradesAPIProtocol {
    private let config = EnvironmentConfiguration.shared.gradesAPI
    private let httpService: HttpServiceProtocol
    var settings: SettingsRepositoryProtocol?

    private var baseUrl: String {
        return config["BaseURL"]!
    }

    // TODO: refactor to observable
    private var defaultParameters: [String: Any] {
        guard let settings = settings else { return [:] }
        let settingsState = settings.currentSettings.value

        var parameters = [
            "lang": settingsState.language.rawValue
        ]
        parameters["semester"] = settingsState.semester

        return parameters
    }

    init(httpService: HttpServiceProtocol) {
        self.httpService = httpService
    }

    // MARK: API endpoints

    private enum Endpoint {
        case userInfo
        case roles
        case courses(String)
        case course(String)
        case studentCourse(String, String)
        case semester
    }

    // MARK: Endpoint requests

    /// Fetch user info and roles
    func getUser() -> Observable<UserInfo> {
        return httpService.get(url: createURL(from: .userInfo), parameters: nil)
    }

    /// Fetch user roles
    func getRoles() -> Observable<UserRoles> {
        return httpService.get(url: createURL(from: .roles), parameters: defaultParameters)
    }

    /// Fetch courses for current user
    func getCourses(username: String) -> Observable<[Course]> {
        return httpService.get(url: createURL(from: .courses(username)), parameters: defaultParameters)
            .map { (rawCourses: [RawCourse]) -> [Course] in
                rawCourses.map { (course: RawCourse) -> Course in Course(fromRawCourse: course) }
            }
    }

    /// Fetch course detail
    func getCourse(code: String) -> Observable<CourseDetailRaw> {
        return httpService.get(url: createURL(from: .course(code)), parameters: defaultParameters)
    }

    /// Fetch course classification for student
    func getCourseStudentClassification(username: String, code: String) -> Observable<CourseStudent> {
        var parameters = defaultParameters
        parameters["showHidden"] = false

        return httpService.get(url: createURL(from: .studentCourse(username, code)), parameters: parameters)
    }

    func getCurrentSemestrCode() -> Observable<String> {
        return httpService.get(url: createURL(from: .semester), parameters: [:])
    }

    // MARK: helpers

    private func createURL(from endpoint: Endpoint) -> URL {
        var endpointValue = ""

        switch endpoint {
        case .userInfo:
            endpointValue = config["UserInfo"]!
        case .roles:
            endpointValue = config["Roles"]!
        case let .course(code):
            endpointValue = config["Course"]!.replacingOccurrences(of: ":code", with: code)
        case let .courses(username):
            endpointValue = config["Courses"]!.replacingOccurrences(of: ":username", with: username)
        case let .studentCourse(username, code):
            endpointValue = config["StudentCourse"]!
                .replacingOccurrences(of: ":username", with: username)
                .replacingOccurrences(of: ":code", with: code)
        case .semester:
            endpointValue = config["Semester"]!
        }

        return URL(string: "\(baseUrl)\(endpointValue)")!
    }
}
