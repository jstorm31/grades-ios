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
import RxBlocking
@testable import GradesDev

class DynamicValueCellViewModelTests: XCTestCase {
	var scheduler: TestScheduler!
	var cellViewModel: DynamicValueCellViewModel!
	var bag = DisposeBag()

    override func setUp() {
		scheduler = TestScheduler(initialClock: 0)
        cellViewModel = DynamicValueCellViewModel(key: "testCell")
		cellViewModel.bindOutput()
    }
	
	func testStringValue() {
		let showTextField = scheduler.createObserver(Bool.self)
		let stringValue = scheduler.createObserver(String?.self)

		cellViewModel.showTextField.bind(to: showTextField).disposed(by: bag)
		cellViewModel.stringValue.bind(to: stringValue).disposed(by: bag)

		scheduler
			.createColdObservable([.next(10, DynamicValue.string("B"))])
			.bind(to: cellViewModel.value)
			.disposed(by: bag)
		scheduler.start()
		
		XCTAssertEqual(showTextField.events, [.next(10, true)])
		XCTAssertEqual(stringValue.events, [.next(10, "B")])
	}
	
	func testNumberValue() {
		let showTextField = scheduler.createObserver(Bool.self)
		let stringValue = scheduler.createObserver(String?.self)
		
		cellViewModel.showTextField.bind(to: showTextField).disposed(by: bag)
		cellViewModel.stringValue.bind(to: stringValue).disposed(by: bag)
		
		scheduler
			.createColdObservable([.next(10, DynamicValue.number(14.5))])
			.bind(to: cellViewModel.value)
			.disposed(by: bag)
		scheduler.start()
		
		XCTAssertEqual(showTextField.events, [.next(10, true)])
		XCTAssertEqual(stringValue.events, [.next(10, "14.5")])
	}
	
	func testBoolValue() {
		let showTextField = scheduler.createObserver(Bool.self)
		let boolValue = scheduler.createObserver(Bool.self)
		
		cellViewModel.showTextField.bind(to: showTextField).disposed(by: bag)
		cellViewModel.boolValue.debug().bind(to: boolValue).disposed(by: bag)
		
		scheduler
			.createColdObservable([.next(10, DynamicValue.bool(false))])
			.bind(to: cellViewModel.value)
			.disposed(by: bag)
		scheduler.start()
		
		XCTAssertEqual(showTextField.events, [.next(10, false)])
		XCTAssertEqual(boolValue.events, [.next(10, false)])
	}

}
