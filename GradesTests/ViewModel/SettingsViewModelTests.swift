//
//  SettingsViewModelTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 10/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
@testable import GradesDev

class SettingsViewModelTests: XCTestCase {
	var scheduler: ConcurrentDispatchQueueScheduler!
	var viewModel: SettingsViewModel!
	
	override func setUp() {
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		viewModel = SettingsViewModel(dependencies: AppDependencyMock.shared)
	}
	
	func testDataSource() {
		let settings = viewModel.settings.subscribeOn(scheduler)
		viewModel.bindOutput()
		
		let result = try! settings.toBlocking(timeout: 2).first()!
		XCTAssertEqual(result.count, 3)
		XCTAssertEqual(result[0].items.count, 2)
		XCTAssertEqual(result[1].items.count, 1)
	}
}
