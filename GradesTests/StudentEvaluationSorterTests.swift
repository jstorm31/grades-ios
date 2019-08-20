//
//  StudentEvaluationSorterTest.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 20/08/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
@testable import GradesDev

class StudentEvaluationSorterTest: XCTestCase {
	var items: [StudentClassification]!
	
	override func setUp() {
		items = [
			StudentClassification(ident: "a", firstName: "Jana", lastName: "Křehká", username: "krehjana", value: DynamicValue.number(18.0 as Double?)),
			StudentClassification(ident: "b", firstName: "Ivan", lastName: "Dlouhý", username: "dlouhiv4", value: DynamicValue.number(34.0 as Double?)),
			StudentClassification(ident: "c", firstName: "Ondřej", lastName: "Kvítko", username: "kvitond", value: DynamicValue.number(41.0 as Double?)),
			StudentClassification(ident: "d", firstName: "Zdeněk", lastName: "Zhor", username: "zhorzden", value: DynamicValue.number(10.0 as Double?)),
		]
	}

	func testSortByName() {
		let sorter = StudentClassificationNameSorter()
		let sorted = sorter.sort(classifications: items).map { $0.username }
		
		XCTAssertEqual(sorted, ["dlouhiv4", "krehjana", "kvitond", "zhorzden"])
    }
	
	func testSortByPoints() {
		let sorter = StudentClassificationValueSorter()
		let sorted = sorter.sort(classifications: items).map { $0.username }
		
		XCTAssertEqual(sorted, ["kvitond", "dlouhiv4", "krehjana", "zhorzden"])
	}
	
	func testSortByGrade() {
		items[0].value = DynamicValue.string("C")
		items[1].value = DynamicValue.string("E")
		items[2].value = DynamicValue.string("C")
		items[3].value = DynamicValue.string("A")
		
		let sorter = StudentClassificationValueSorter()
		let sorted = sorter.sort(classifications: items).map { $0.username }
		
		XCTAssertEqual(sorted, ["zhorzden", "krehjana", "kvitond", "dlouhiv4"])
	}
	
	func testSortByBool() {
		items[0].value = DynamicValue.bool(true)
		items[1].value = DynamicValue.bool(true)
		items[2].value = DynamicValue.bool(false)
		items[3].value = DynamicValue.bool(false)

		let sorter = StudentClassificationValueSorter()
		let sorted = sorter.sort(classifications: items).map { $0.username }
		
		XCTAssertEqual(sorted, ["zhorzden", "krehjana", "kvitond", "dlouhiv4"])
	}
	
	func testSortByPointsWithNil() {
		items[1].value = nil // should be at the end
		
		let sorter = StudentClassificationValueSorter()
		let sorted = sorter.sort(classifications: items).map { $0.username }
		
		XCTAssertEqual(sorted, ["kvitond", "krehjana", "zhorzden", "dlouhiv4"])
	}
}
