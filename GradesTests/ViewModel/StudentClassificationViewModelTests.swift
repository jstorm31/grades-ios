//
//  StudentClassificationViewModelTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 18/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import GradesDev

class StudentClassificationViewModelTests: XCTestCase {
	var scheduler: ConcurrentDispatchQueueScheduler!
	var viewModel: StudentClassificationViewModel!
	var coordinator: SceneCoordinatorMock!
	var gradesApi = AppDependencyMock.shared._gradesApi
	
    override func setUp() {
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		coordinator = SceneCoordinatorMock()
		viewModel = StudentClassificationViewModel(dependencies: AppDependencyMock.shared, coordinator: coordinator, course: Course(code: "MI-IOS"))
    }

	func testBindStudents() {
		gradesApi.result = .success
		let studentsObservable = viewModel.students.subscribeOn(scheduler)
		viewModel.bindOutput()

		do {
			guard let students = try studentsObservable.skip(1).toBlocking(timeout: 2).first() else {
				XCTFail("should not be nil")
				return
			}
			
			XCTAssertEqual(students.count, 3)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testBindStudentName() {
		gradesApi.result = .success
		let studentObservable = viewModel.studentName.subscribeOn(scheduler)
		viewModel.bindOutput()

		do {
			guard let result = try studentObservable.toBlocking(timeout: 2).first() else {
				XCTFail("should not be nil")
				return
			}
			
			XCTAssertEqual(result, "Jan Kučera")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testDataSource() {
		gradesApi.result = .success
		let dataSourceObservable = viewModel.dataSource.subscribeOn(scheduler)
		viewModel.bindOutput()

		do {
			guard let result = try dataSourceObservable.skip(1).toBlocking(timeout: 2).first() else {
				XCTFail("should not be nil")
				return
			}
			
			XCTAssertEqual(result.count, 1)
			XCTAssertEqual(result[0].items.count, 9, "filtered manual classifications")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testError() {
		gradesApi.result = .failure
		let errorObservable = viewModel.error.subscribeOn(scheduler)
		viewModel.bindOutput()

		do {
			guard let result = try errorObservable.skip(1).toBlocking(timeout: 2).first() else {
				XCTFail("should not be nil")
				return
			}

			XCTAssertNotNil(result)
			XCTAssertEqual(result as! ApiError, .general)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testTransitionToStudentSearch() {
		let _ = viewModel.changeStudentAction.execute().subscribeOn(scheduler).toBlocking(timeout: 1).materialize()
		
		XCTAssertNotNil(coordinator.targetScene)
		if case .studentSearch = coordinator.targetScene! {
			XCTAssertTrue(true) // Success
		} else {
			XCTFail("incorrect scene")
		}
	}

}
