//
//  TeacherRepositoryTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 10/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
@testable import Grades

class TeacherRepositoryTests: XCTestCase {
	var scheduler: ConcurrentDispatchQueueScheduler!
	var repository: TeacherRepository!
	var gradesApi = AppDependencyMock.shared._gradesApi

    override func setUp() {
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		repository = TeacherRepository(dependencies: AppDependencyMock.shared)
    }
	
	func testGroupOptions() {
		gradesApi.result = .success
		let groups = repository.groups.observeOn(scheduler)
		repository.getGroupOptions(forCourse: "")
		let result = try! groups.skip(1).toBlocking(timeout: 2).first()!

		XCTAssertEqual(result.count, 2)
	}
	
	func testClassificationOptions() {
		gradesApi.result = .success
		let classifications = repository.classifications.observeOn(scheduler)
		repository.getClassificationOptions(forCourse: "")
		let result = try! classifications.skip(1).toBlocking(timeout: 3).first()!
		
		XCTAssertEqual(result.count, 2)
	}

	func testStudentClassifications() {
		gradesApi.result = .success
		let classifications = try! repository.studentClassifications(course: "", groupCode: "", classificationId: "")
			.observeOn(scheduler).toBlocking(timeout: 2).first()!
		XCTAssertEqual(classifications.count, 3)
	}
}
