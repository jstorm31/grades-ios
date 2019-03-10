//
//  CourseListViewModelTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 06/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import GradesDev

class CourseListViewModelTests: XCTestCase {
	var viewModel: CourseListViewModel!
	var scheduler: ConcurrentDispatchQueueScheduler!
	var mockUser: UserInfo!
	var gradesApiMock: GradesAPIMock!
	
	override func setUp() {
		mockUser = GradesAPIMock.userInfo
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		gradesApiMock = GradesAPIMock()
		viewModel = CourseListViewModel(api: gradesApiMock, user: mockUser)
	}
	
	override func tearDown() {
	}
	
	func testMapCoursesToRoles() {
		let coursesObservable = viewModel.courses.asObservable().subscribeOn(scheduler)
		let coursesErrorObservable = viewModel.coursesError.asObservable().subscribeOn(scheduler)
		
		viewModel.bindOutput()
		
		do {
			guard let result = try coursesObservable.toBlocking(timeout: 1.0).first() else { return }
			guard let courseError = try coursesErrorObservable.toBlocking(timeout: 1).first() else { return }

			XCTAssertTrue(courseError == nil, "emits no error")
			XCTAssertEqual(result.count, 2, "has two groups of subjects")
			XCTAssertEqual(result[0].header, "Studying", "has right header name")
			XCTAssertEqual(result[0].items.count, 2, "has right data")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testErrorHandling() {
		gradesApiMock.result = .failure
		
		let coursesObservable = viewModel.courses.asObservable().subscribeOn(scheduler)
		let coursesErrorObservable = viewModel.coursesError.asObservable().subscribeOn(scheduler)
		
		viewModel.bindOutput()
		
		do {
			guard let courses = try coursesObservable.toBlocking(timeout: 1.0).first() else { return }
			guard let courseError = try coursesErrorObservable.toBlocking(timeout: 1).first() else { return }
			
			XCTAssertTrue(courses.isEmpty, "emits no data")
			XCTAssertNotNil(courseError, "emits error of right type")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
}
