//
//  StudentGroupTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 13/09/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
@testable import GradesDev

class StudentGroupTests: XCTestCase {

    func testReplaceLocalizationKeys() {
		let group = StudentGroup(id: "PARALLEL_1013979289005", name: "{PARALLEL_TUTORIAL}104 -  ({DAY_2} 11:00) Ing. Josef Malík", description: nil)
		
		XCTAssertEqual(group.title(), "Tutorial n. 104 -  (tuesday 11:00) Ing. Josef Malík")
    }
	
	func testDoesNotReplace() {
		let group = StudentGroup(id: "EVENT_1048118388405", name: "Opravný semestrální test: 17.05.2019", description: nil)
		
		XCTAssertEqual(group.title(), "Opravný semestrální test: 17.05.2019")
	}

}
