//
//  GradesAPI.swift
//  Grades
//
//  Created by Jiří Zdvomka on 03/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxSwift

protocol HasGradesAPI {
    var gradesApi: GradesAPIProtocol { get }
}

protocol GradesAPIProtocol {
    func getUser() -> Observable<User>
    func getTeacherCourses(username: String) -> Observable<[TeacherCourse]>
    func getStudentCourses(username: String) -> Observable<[StudentCourse]>
    func getCourse(code: String) -> Observable<Course>
    func getCourseStudentClassification(username: String, code: String) -> Observable<[Classification]>
    func getCurrentSemestrCode() -> Observable<String>
    func getStudentGroups(forCourse course: String, username: String?) -> Observable<[StudentGroup]>
    func getClassifications(forCourse: String) -> Observable<[Classification]>
    func getGroupClassifications(courseCode: String, groupCode: String, classificationId: String) -> Observable<[StudentClassification]>
    func getTeacherStudents(courseCode: String) -> Observable<[User]>

    func putStudentsClassifications(courseCode: String, data: [StudentClassification]) -> Observable<Void>
}

final class GradesAPI: GradesAPIProtocol {
    typealias Depencencies = HasSettingsRepository & HasHttpService

    private let dependencies: Depencencies
    private let httpService: HttpServiceProtocol
    private let config = EnvironmentConfiguration.shared.gradesAPI

    private var baseUrl: String {
        return config["BaseURL"]!
    }

    private var defaultParameters: [String: Any] {
        let settingsState = dependencies.settingsRepository.currentSettings.value

        var parameters = [
            "lang": settingsState.language.rawValue
        ]
        parameters["semester"] = settingsState.semester

        return parameters
    }

    init(dependencies: Depencencies) {
        self.dependencies = dependencies
        httpService = dependencies.httpService
    }

    // MARK: API endpoints

    private enum Endpoint {
        case userInfo
        case roles
        case courses(String)
        case course(String)
        case studentCourse(String, String)
        case semester
        case studentGroups(String)
        case courseClassifications(String)
        case groupClassifications(String, String, String)
        case courseStudents(String, String)
        case studentsClassifications(String)
    }

    // MARK: GET requests

    /// Fetch user info and roles
    func getUser() -> Observable<User> {
        return httpService.get(url: createURL(from: .userInfo), parameters: nil)
    }

    /// Fetch user courses by their roles
    func getTeacherCourses(username _: String) -> Observable<[TeacherCourse]> {
        return httpService.get(url: createURL(from: .roles), parameters: defaultParameters)
            .map { (raw: CoursesByRolesRaw) -> [TeacherCourse] in
                raw.teacherCourses.map { (courseCode: String) -> TeacherCourse in TeacherCourse(code: courseCode) }
            }
    }

    /// Fetch courses for current user
    func getStudentCourses(username: String) -> Observable<[StudentCourse]> {
        return httpService.get(url: createURL(from: .courses(username)), parameters: defaultParameters)
            .map { (rawCourses: [StudentCourseRaw]) -> [StudentCourse] in
                rawCourses.map { (course: StudentCourseRaw) -> StudentCourse in StudentCourse(fromRawCourse: course) }
            }
    }

    /// Fetch course detail
    func getCourse(code: String) -> Observable<Course> {
        return httpService.get(url: createURL(from: .course(code)), parameters: defaultParameters)
    }

    /// Fetch course classification for student
    func getCourseStudentClassification(username: String, code: String) -> Observable<[Classification]> {
        var parameters = defaultParameters
        parameters["showHidden"] = false

        return httpService.get(url: createURL(from: .studentCourse(username, code)), parameters: parameters)
            .map { (raw: StudentClassifications) in raw.classifications }
    }

    func getCurrentSemestrCode() -> Observable<String> {
        return httpService.get(url: createURL(from: .semester), parameters: [:])
    }

    /// Fetch student groups for course
    func getStudentGroups(forCourse course: String, username: String? = nil) -> Observable<[StudentGroup]> {
        let url = createURL(from: .studentGroups(course))
        var parameters = defaultParameters

        if let username = username {
            parameters["teacherUsername"] = username
        }

        return httpService.get(url: url, parameters: parameters)
    }

    /// Fetch classifications for course
    func getClassifications(forCourse course: String) -> Observable<[Classification]> {
        let url = createURL(from: .courseClassifications(course))
        return httpService.get(url: url, parameters: defaultParameters)
    }

    /// Fetch items for student grou and classification
    func getGroupClassifications(courseCode: String, groupCode: String, classificationId: String) -> Observable<[StudentClassification]> {
        let url = createURL(from: .groupClassifications(courseCode, groupCode, classificationId))
        return httpService.get(url: url, parameters: defaultParameters)
    }

    /// Fetch all students for logged user with role teacher
    func getTeacherStudents(courseCode: String) -> Observable<[User]> {
        // swiftlint:disable force_cast
        if let environment = Bundle.main.infoDictionary!["ConfigEnvironment"], (environment as! String) == "Debug" {
            // Return mock data in Debug
            return Observable.just([
                User(userId: 2, username: "janatpa3", firstName: "Pavel", lastName: "Janata"),
                User(userId: 1, username: "rousemat", firstName: "Matyáš", lastName: "Rousek"),
                User(userId: 3, username: "ottastep", firstName: "Štěpán", lastName: "Otta")
            ]).delaySubscription(1, scheduler: MainScheduler.instance)
        } else {
            // Get from API in Release
            let url = createURL(from: .courseStudents(courseCode, "MY_PARALLELS"))
            return httpService.get(url: url, parameters: defaultParameters)
        }
    }

    // MARK: PUT requests

    func putStudentsClassifications(courseCode: String, data _: [StudentClassification]) -> Observable<Void> {
        let url = createURL(from: .studentsClassifications(courseCode))
        //		return httpService.put(url: url, parameters: defaultParameters, body: data)
        return Observable.empty()
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
        case let .studentGroups(courseCode):
            endpointValue = config["StudentGroups"]!
                .replacingOccurrences(of: ":courseCode", with: courseCode)
        case let .courseClassifications(courseCode):
            endpointValue = config["CourseClassifications"]!
                .replacingOccurrences(of: ":courseCode", with: courseCode)
        case let .groupClassifications(courseCode, groupCode, classificationId):
            endpointValue = config["GroupClassifications"]!
                .replacingOccurrences(of: ":courseCode", with: courseCode)
                .replacingOccurrences(of: ":groupCode", with: groupCode)
                .replacingOccurrences(of: ":id", with: classificationId)
        case let .courseStudents(courseCode, groupCode):
            endpointValue = config["CourseStudents"]!
                .replacingOccurrences(of: ":courseCode", with: courseCode)
                .replacingOccurrences(of: ":groupCode", with: groupCode)
        case let .studentsClassifications(courseCode):
            endpointValue = config["StudentsClassifications"]!
                .replacingOccurrences(of: ":courseCode", with: courseCode)
        }

        return URL(string: "\(baseUrl)\(endpointValue)")!
    }
}
