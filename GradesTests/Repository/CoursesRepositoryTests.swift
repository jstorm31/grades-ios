//
//  CoursesRepositoryTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 12/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import GradesDev

class CoursesRepositoryTests: XCTestCase {
	var scheduler: ConcurrentDispatchQueueScheduler!
	var repository: CoursesRepository!
	var gradesApi = AppDependencyMock.shared._gradesApi

    override func setUp() {
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		repository = CoursesRepository(dependencies: AppDependencyMock.shared)
    }

    func testGetUserCourses() {
		let coursesObservable = repository.userCourses.asObservable().subscribeOn(scheduler)
		let coursesErrorObservable = repository.error.asObservable().subscribeOn(scheduler)
		repository.getUserCourses(username: "mockuser")
		
		do {
			guard let result = try coursesObservable.toBlocking(timeout: 1.0).first() else { return }
			guard let courseError = try coursesErrorObservable.toBlocking(timeout: 1).first() else { return }
			
			XCTAssertTrue(courseError == nil, "emits no error")
			XCTAssertEqual(result.student.count, 2, "has right student course count")
			XCTAssertEqual(result.student[0].code, "BI-ZMA")
			XCTAssertEqual(result.student[0].name!, "Programming paradigmas", "has a name")
			XCTAssertNotNil(result.student[0].finalValue, "has final value")
			XCTAssertEqual(result.teacher.count, 2, "has right teacher course count")
			XCTAssertEqual(result.teacher[1].code, "BI-OOP", "has right course code")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testGetUserCoursesError() {
		gradesApi.result = .failure
		
		let coursesObservable = repository.userCourses.asObservable().subscribeOn(scheduler)
		let coursesErrorObservable = repository.error.asObservable().subscribeOn(scheduler)
		repository.getUserCourses(username: "mockuser")

		do {
			guard let courses = try coursesObservable.toBlocking(timeout: 1.0).first() else { return }
			guard let courseError = try coursesErrorObservable.toBlocking(timeout: 1).first() else { return }
			
			XCTAssertTrue(courses.student.isEmpty, "emits no data")
			XCTAssertTrue(courses.teacher.isEmpty, "emits no data")
			XCTAssertNotNil(courseError, "emits error of right type")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

}
