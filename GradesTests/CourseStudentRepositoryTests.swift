//
//  CourseStudentRepositoryTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 15/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import GradesDev

class CourseStudentRepositoryTests: XCTestCase {
	var scheduler: ConcurrentDispatchQueueScheduler!
	var repository: CourseStudentRepository!

    override func setUp() {
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		repository = CourseStudentRepository(username: "mockuser", code: "BI-PPA", name: nil, gradesApi: GradesAPIMock())
	}

    override func tearDown() {}

    func testGroupsClassifications() {
		let classificationsObservable = repository.groupedClassifications.debug().subscribeOn(scheduler)
		repository.bindOutput()
		
		do {
			guard let result = try classificationsObservable.toBlocking(timeout: 1).first() else {
				XCTFail("should have emitted event")
				return
			}
			
			XCTAssertEqual(result.count, 4, "has right number of groups")
			XCTAssertEqual(result[1].header, "Exam", "has correct header title")
			XCTAssertEqual(result[0].items.count, 3, "first section has right number of child items")
			XCTAssertEqual(result[1].items.count, 3, "second seciton has right number of child items")
		} catch {
			XCTFail(error.localizedDescription)
		}
    }

}
