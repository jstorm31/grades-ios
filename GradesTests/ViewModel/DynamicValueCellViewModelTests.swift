//
//  DynamicValueCellViewModelTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 20/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import Grades

class DynamicValueCellViewModelTests: XCTestCase {
	var scheduler: TestScheduler!
	var cellViewModel: DynamicValueCellViewModel!
	var bag = DisposeBag()

    override func setUp() {
		scheduler = TestScheduler(initialClock: 0)
    }
	
	func testStringValue() {
		cellViewModel = DynamicValueCellViewModel(valueType: .string, evaluationType: .manual, key: "testCell")
		cellViewModel.bindOutput()
		
		let stringValue = scheduler.createObserver(String?.self)
		cellViewModel.stringValue.bind(to: stringValue).disposed(by: bag)

		scheduler
			.createColdObservable([.next(10, DynamicValue.string("B"))])
			.bind(to: cellViewModel.value)
			.disposed(by: bag)
		scheduler.start()
		
		XCTAssertEqual(stringValue.events, [.next(10, "B")])
	}
	
	func testNumberValue() {
		cellViewModel = DynamicValueCellViewModel(valueType: .number, evaluationType: .manual, key: "testCell")
		cellViewModel.bindOutput()

		let stringValue = scheduler.createObserver(String?.self)
		cellViewModel.stringValue.bind(to: stringValue).disposed(by: bag)
		
		scheduler
			.createColdObservable([.next(10, DynamicValue.number(14.5))])
			.bind(to: cellViewModel.value)
			.disposed(by: bag)
		scheduler.start()
		
		XCTAssertEqual(stringValue.events, [.next(10, "14.5")])
	}
	
	func testBoolValue() {
		cellViewModel = DynamicValueCellViewModel(valueType: .bool, evaluationType: .manual, key: "testCell")
		cellViewModel.bindOutput()

		let boolValue = scheduler.createObserver(Bool.self)
		cellViewModel.boolValue.bind(to: boolValue).disposed(by: bag)
		
		scheduler
			.createColdObservable([.next(10, DynamicValue.bool(false))])
			.bind(to: cellViewModel.value)
			.disposed(by: bag)
		scheduler.start()
		
		XCTAssertEqual(boolValue.events, [.next(10, false)])
	}

}
