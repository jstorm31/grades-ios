//
//  File.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 06/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift

class GradesAPIMock: GradesAPIProtocol {
    // MARK: mock data with default values

    var userRoles = UserRoles(studentCourses: ["BI-PST", "BI-PPA"], teacherCourses: ["BI-ZMA", "MI-IOS"])

    var userInfo = UserInfo(userId: 14, username: "mockuser", firstName: "Ondřej", lastName: "Krátký")

    var courses = [
        Course(code: "BI-PST", items: [
            OverviewItem(type: "ASSESMENT", value: "11"),
            OverviewItem(type: "POINTS_TOTAL", value: "5"),
        ]),
        Course(code: "BI-PPA", items: [
            OverviewItem(type: "ASSESMENT", value: nil),
            OverviewItem(type: "POINTS_TOTAL", value: "4"),
        ]),
        Course(code: "MI-IOS", items: [
            OverviewItem(type: "ASSESMENT", value: nil),
            OverviewItem(type: "POINTS_TOTAL", value: nil),
        ]),
    ]

    // MARK: methods

    func getUser() -> Observable<User> {
        return Observable<User>.just(User(info: userInfo, roles: userRoles))
    }

    func getRoles() -> Observable<UserRoles> {
        return Observable<UserRoles>.just(userRoles)
    }

    func getCourses() -> Observable<[Course]> {
        return Observable.just(courses)
    }
}