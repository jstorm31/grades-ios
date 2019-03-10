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
	var result = Result.success
	
	enum Result {
		case success
		case failure
	}

    var userRoles = UserRoles(studentCourses: ["BI-PST", "BI-PPA"], teacherCourses: ["BI-ZMA", "MI-IOS"])

    static var userInfo = UserInfo(userId: 14, username: "mockuser", firstName: "Ondřej", lastName: "Krátký")

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


    // MARK: methods

    func getUser() -> Observable<UserInfo> {
		switch result {
		case .success:
			return Observable.just(GradesAPIMock.userInfo)
		case .failure:
			return Observable.error(ApiError.general)
		}
    }

    func getRoles() -> Observable<UserRoles> {
        return Observable.just(userRoles)
    }

    func getCourses(username _: String) -> Observable<[Course]> {
		switch result {
		case .success:
			return Observable.just(courses)
		case .failure:
			return Observable.create { observer in
				observer.onError(ApiError.general)
				return Disposables.create()
			}
		}
    }
}
