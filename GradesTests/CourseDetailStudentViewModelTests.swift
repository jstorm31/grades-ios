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
	var viewModel: CourseDetailStudentViewModel!
	
    override func setUp() {
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		let repoMock = CourseStudentRepositoryMock()
		viewModel = CourseDetailStudentViewModel(coordinator: SceneCoordinatorMock(), repository: repoMock)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
		let totaPointsObservable = viewModel.totalGrade.subscribeOn(scheduler)
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
