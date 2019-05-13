//
//  CourseDetailStudentViewModelTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 04/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
@testable import GradesDev

class CourseDetailStudentViewModelTests: XCTestCase {
	var scheduler: ConcurrentDispatchQueueScheduler!
	var sceneMock = AppDependencyMock.shared._coordinator
	var gradesApi = AppDependencyMock.shared._gradesApi
	var viewModel: CourseDetailStudentViewModel!

    override func setUp() {
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		viewModel = CourseDetailStudentViewModel(dependencies: AppDependencyMock.shared, course: Course(code: "BI-PPA"))
    }

    func testGroupedClassifications() {
		gradesApi.result = .success
		let classificationsObservable = viewModel.classifications.subscribeOn(scheduler)
		viewModel.bindOutput()
		
		do {
			guard let groups = try classificationsObservable.skip(1).toBlocking(timeout: 2).first() else {
				XCTFail("should not be nil")
				return
			}
			
			XCTAssertEqual(groups.count, 1)
			XCTAssertEqual(groups[0].items.count, 7, "filter out final grade and total points + isHidden")
		} catch {
			XCTFail(error.localizedDescription)
		}
    }
	
	func testTotalPoints() {
		gradesApi.result = .success
		let pointsObservable = viewModel.totalPoints.subscribeOn(scheduler)
		viewModel.bindOutput()
		
		let points = try! pointsObservable.skip(1).toBlocking(timeout: 2).first()
		XCTAssertEqual(points, 64.0)
	}
	
	func testFinalGrade() {
		gradesApi.result = .success
		let gradeObservable = viewModel.finalGrade.subscribeOn(scheduler)
		viewModel.bindOutput()
		
		let grade = try! gradeObservable.skip(1).toBlocking(timeout: 2).first()
		XCTAssertEqual(grade, "D")
	}
}
