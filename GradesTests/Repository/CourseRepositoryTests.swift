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

class CourseRepositoryTests: XCTestCase {
	var scheduler: ConcurrentDispatchQueueScheduler!
	var repository: CourseRepositoryProtocol!
	var gradesApi = AppDependencyMock.shared._gradesApi
    var settings = AppDependencyMock.shared.settingsRepository
	let username = "testuser"

    override func setUp() {
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		repository = CourseRepository(dependencies: AppDependencyMock.shared)
		repository.set(course: Course(code: "MI-IOS"))
	}
	
	func testClassifications() {
		gradesApi.result = .success
		let classificationsObservable = repository.classifications(forStudent: username).subscribeOn(scheduler)
		
		do {
			guard let result = try classificationsObservable.toBlocking(timeout: 2).first() else {
				XCTFail("should have emitted event")
				return
			}
			
			XCTAssertEqual(result.count, 10, "has right number of items")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
    func testGroupedClassifications() {
		gradesApi.result = .success
		let classificationsObservable = repository.groupedClassifications(forStudent: username).subscribeOn(scheduler)
		
		do {
			guard let result = try classificationsObservable.toBlocking(timeout: 2).first() else {
				XCTFail("should have emitted event")
				return
			}
			
			XCTAssertEqual(result.count, 3, "has right number of groups")
			XCTAssertEqual(result[0].items.count, 3, "show parent item with no childs in the first group")
			XCTAssertEqual(result[1].items.count, 3, "first section has right number of child items")
			XCTAssertEqual(result[2].items.count, 2, "second seciton has right number of child items")
			XCTAssertEqual(result[1].header, "Exam", "has correct header title")
		} catch {
			XCTFail(error.localizedDescription)
		}
    }
    
    func testUndefinedEvaluationHidden() {
        gradesApi.result = .success
        
        var newSettings = settings.currentSettings.value
        newSettings.undefinedEvaluationHidden = true
        settings.currentSettings.accept(newSettings)
        
        let classificationsObservable = repository.groupedClassifications(forStudent: username).subscribeOn(scheduler)
        let result = try! classificationsObservable.toBlocking(timeout: 2).first()!
        
        Log.debug("\(result[0].items.map { ($0.id, $0.value) } )")
        
        XCTAssertEqual(result[0].items.count, 2)
    }
	
	func testOverview() {
		gradesApi.result = .success
		let overviewObservable = repository.overview(forStudent: username).subscribeOn(scheduler)
		
		do {
			guard let result = try overviewObservable.toBlocking(timeout: 2).first() else {
				XCTFail("should have emitted event")
				return
			}
			
			XCTAssertEqual(result.totalPoints, 73.5, "has correct total points")
			XCTAssertEqual(result.finalGrade, "B", "has correct final grade")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testError() {
		gradesApi.result = .failure
		let errorObservable = repository.error.subscribeOn(scheduler)
		let _ = repository.classifications(forStudent: username).subscribeOn(scheduler).toBlocking().materialize()
		
		do {
			guard let result = try errorObservable.toBlocking(timeout: 2).first() else {
				XCTFail("should have emitted event")
				return
			}
			
			XCTAssertNotNil(result)
			XCTAssertEqual(result as! ApiError, .general)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
}
