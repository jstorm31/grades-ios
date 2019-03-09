//
//  File.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 06/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
@testable import GradesDev

class GradesAPIMock: GradesAPIProtocol {
    // MARK: mock data with default values

    var userRoles = UserRoles(studentCourses: ["BI-PST", "BI-PPA"], teacherCourses: ["BI-ZMA", "MI-IOS"])

    var userInfo = UserInfo(userId: 14, username: "mockuser", firstName: "Ondřej", lastName: "Krátký")

    var courses = [
        Course(code: "BI-PST", items: [
            OverviewItem(type: "ASSESMENT", value: "11"),
            OverviewItem(type: "POINTS_TOTAL", value: "5")
        ]),
        Course(code: "BI-PPA", items: [
            OverviewItem(type: "ASSESMENT", value: nil),
            OverviewItem(type: "POINTS_TOTAL", value: "4"),
        ]),
        Course(code: "MI-IOS", items: [
            OverviewItem(type: "ASSESMENT", value: nil),
            OverviewItem(type: "POINTS_TOTAL", value: nil)
        ])
    ]

    private let emitError: Bool

    init(emitError: Bool = false) {
        self.emitError = emitError
    }

    // MARK: methods

    func getUser() -> Observable<UserInfo> {
        return Observable.just(userInfo)
    }

    func getRoles() -> Observable<UserRoles> {
        return Observable.just(userRoles)
    }

    func getCourses(username _: String) -> Observable<[Course]> {
        if emitError {
            return Observable.create { observer in
                observer.onError(ApiError.general)
                return Disposables.create()
            }
        } else {
            return Observable.just(courses)
        }
    }
}
