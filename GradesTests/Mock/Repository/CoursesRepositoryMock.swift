//
//  CoursesRepository.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 27/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import RxCocoa
@testable import GradesDev

final class CoursesRepositoryMock: CoursesRepositoryProtocol {
	private let courses = CoursesByRoles(student: [
		StudentCourse(code: "BI-PPA", finalValue: .number(4)),
		StudentCourse(code: "BI-ZMA", finalValue: .string("C")),
		], teacher: [
			TeacherCourse(code: "MI-IOS"),
			TeacherCourse(code: "BI-PST")
		])
	
	var result: Result = .success
	
	var userCourses = BehaviorRelay<CoursesByRoles>(value: CoursesByRoles(student: [], teacher: []))
	var isFetching = BehaviorSubject<Bool>(value: false)
	var error = BehaviorSubject<Error?>(value: nil)
	
	func getUserCourses(username: String) {
		switch result {
		case .success:
			userCourses.accept(courses)
		case .failure:
			error.onNext(ApiError.general)
		}
	}
}
