//
//  CourseDetailStudentViewModelTests.swift
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

class CourseDetailStudentViewModelTests: XCTestCase {
	var scheduler: ConcurrentDispatchQueueScheduler!
	var repoMock: CourseStudentRepositoryMock!
	var viewModel: CourseDetailStudentViewModel!
	
	override func setUp() {
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		repoMock = CourseStudentRepositoryMock()
		viewModel = CourseDetailStudentViewModel(coordinator: SceneCoordinatorMock(), )
	}
	
	func testGroupedClassifications() {
		let totaPointsObservable = viewModel.classifications.subscribeOn(scheduler)
		let errorObservable = viewModel.error.subscribeOn(scheduler)
		viewModel.bindOutput()
		
		do {
			guard let result = try totaPointsObservable.toBlocking(timeout: 1).first() else {
				XCTFail("should have emitted event")
				return
			}
			guard let resultError = try errorObservable.toBlocking(timeout: 1).first() else {
				XCTFail("should have emitted event")
				return
			}
			
			XCTAssertNil(resultError, "does not emit error")
			XCTAssertEqual(result.count, 1, "has items")
			XCTAssertNil(result.first { $0.type == ClassificationType.pointsTotal.rawValue || $0.type == ClassificationType.finalScore.rawValue})
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testError() {
		repoMock.emitError = true
		let errorObservable = viewModel.error.subscribeOn(scheduler)
		viewModel.bindOutput()
		
		do {
			guard let result = try errorObservable.toBlocking(timeout: 1).first() else {
				XCTFail("should have emitted event")
				return
			}
			
			XCTAssertNotNil(result, "emmits error")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testTotalPoints() {
		let totaPointsObservable = viewModel.totalPoints.subscribeOn(scheduler)
		viewModel.bindOutput()
		
		do {
			guard let result = try totaPointsObservable.toBlocking(timeout: 1).first() else {
				XCTFail("should have emitted event")
				return
			}
			
			XCTAssertEqual(result, 73.5, "has correct total points")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testTotalGrade() {
		let totaPointsObservable = viewModel.finalGrade.subscribeOn(scheduler)
		viewModel.bindOutput()
		
		do {
			guard let result = try totaPointsObservable.toBlocking(timeout: 1).first() else {
				XCTFail("should have emitted event")
				return
			}
			
			XCTAssertEqual(result, "B", "has correct total grade")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
}
