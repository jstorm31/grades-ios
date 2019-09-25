//
//  GroupClassificationViewModelTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 10/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
@testable import GradesDev

class GroupClassificationViewModelTests: XCTestCase {
	var scheduler: ConcurrentDispatchQueueScheduler!
	var viewModel: GroupClassificationViewModel!
	var gradesApi = AppDependencyMock.shared._gradesApi
	
    override func setUp() {
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		viewModel = GroupClassificationViewModel(dependencies: AppDependencyMock.shared, course: Course(code: "MI-IOS"))
	}

	func testBindData() {
		let dataSource = viewModel.dataSource.subscribeOn(scheduler)
		viewModel.bindOutput()
		
		let result = try! dataSource.skip(1).toBlocking(timeout: 2).first()!
		XCTAssertEqual(result.count, 3)
	}
	
	func testSaveAction() {
		gradesApi.result = .success
		viewModel.bindOutput()
		let action = viewModel.saveAction.execute().subscribeOn(scheduler)
		
		let result = try! action.toBlocking(timeout: 2.0).toArray()
		XCTAssert(result.isEmpty)
	}
    
    func testSortingByName() {
        let dataSource = viewModel.dataSource.subscribeOn(scheduler)
        viewModel.bindOutput()
        viewModel.activeSorterIndex.onNext(0)
        
        let result = try! dataSource.skip(1).toBlocking(timeout: 2).first()!
        XCTAssertEqual(result[0].key, "ivtjir")
    }
    
    func testSortingValue() {
        let dataSource = viewModel.dataSource.subscribeOn(scheduler)
        viewModel.bindOutput()
        viewModel.activeSorterIndex.onNext(1)
        
        let result = try! dataSource.skip(1).toBlocking(timeout: 2).first()!
        XCTAssertEqual(result[0].key, "kobljan")
    }
    
    func testSortingDescending() {
        let dataSource = viewModel.dataSource.subscribeOn(scheduler)
        viewModel.bindOutput()
        viewModel.activeSorterIndex.onNext(1)
        viewModel.isAscending.onNext(false)
        
        let result = try! dataSource.skip(1).toBlocking(timeout: 2).first()!
        XCTAssertEqual(result[0].key, "novtom")
    }
}
