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
	var mockUser: User!
	var gradesApiMock: GradesAPIMock!
	
	override func setUp() {
		mockUser = GradesAPIMock.userInfo
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		gradesApiMock = GradesAPIMock()
		viewModel = CourseListViewModel(dependencies: AppDependencyMock.shared, sceneCoordinator: SceneCoordinatorMock(), user: mockUser)
	}
	
	override func tearDown() {
	}
	
	func testTransitionToCourseDetail() {
		// TODO
	}
	
}
