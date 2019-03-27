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
	var scheduler: ConcurrentDispatchQueueScheduler!
	var viewModel: CourseListViewModel!
	var coordinator: SceneCoordinatorMock!
	
	override func setUp() {
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		coordinator = SceneCoordinatorMock()
		viewModel = CourseListViewModel(dependencies: AppDependencyMock.shared,
										sceneCoordinator: coordinator,
										user: GradesAPIMock.userInfo)
	}
	
	func testOnItemSelectionStudentCourse() {
		let indexPath = IndexPath(item: 0, section: 0)
		viewModel.bindOutput()
		viewModel.onItemSelection(indexPath)
		
		XCTAssertNotNil(coordinator.targetScene)
		if case .courseDetailStudent = coordinator.targetScene! {
			XCTAssertTrue(true) // Success
		} else {
			XCTFail("incorrect scene")
		}
	}
	
	func testOnItemSelectionTeacherCourse() {
		let indexPath = IndexPath(item: 1, section: 1)
		viewModel.bindOutput()
		viewModel.onItemSelection(indexPath)
		
		XCTAssertNil(coordinator.targetScene)
	}
}