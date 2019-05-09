//
//  GradesUITests.swift
//  GradesUITests
//
//  Created by Jiří Zdvomka on 03/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest

class GradesUITests: XCTestCase {
	
	private var app: XCUIApplication!
	let dynamicStubs = HTTPDynamicStubs()
	
	let exists = NSPredicate(format: "exists == true")
	let doesNotExist = NSPredicate(format: "exists == false")

    override func setUp() {
        continueAfterFailure = false
		
		dynamicStubs.setUp()

        app = XCUIApplication()
		app.launchArguments = ["--stub-authentication", "--ui-testing"]
		app.launch()
    }

    override func tearDown() {
		dynamicStubs.tearDown()
	}

    func testCourseList() {
		XCTAssertTrue(app.otherElements.containing(.image, identifier:"FullTextLogo").element.exists)
		app.buttons["Login"].tap()

		let jsCell = app.staticTexts["BI-PJS.1"]
		let iosCell = app.staticTexts["MI-IOS"]
		
		expectation(for: exists, evaluatedWith: jsCell, handler: nil)
		expectation(for: exists, evaluatedWith: iosCell, handler: nil)

		waitForExpectations(timeout: 7, handler: nil)
		XCTAssert(jsCell.exists)
		XCTAssert(iosCell.exists)
    }
	
	func testSemesterChange() {
		app.buttons["Login"].tap()
		chooseSemester("B181", currentSemester: "B182")
		
		let jsCell = app.staticTexts["BI-PJS.1"]
		let komCell = app.staticTexts["BI-KOM"]

		expectation(for: doesNotExist, evaluatedWith: jsCell, handler: nil)
		expectation(for: exists, evaluatedWith: komCell, handler: nil)

		waitForExpectations(timeout: 7, handler: nil)
		XCTAssertFalse(jsCell.exists)
		XCTAssert(komCell.exists)
	}
	
	func testCourseDetail() {
		app.buttons["Login"].tap()
		let tablesQuery = app.tables
		let teacherCell = tablesQuery.cells.containing(.staticText, identifier:"28 p").staticTexts["BI-PJS.1"]
		XCTAssert(teacherCell.waitForExistence(timeout: 7))
		teacherCell.tap()
		
		XCTAssert(app.tables.staticTexts.count > 0)
	}
	
	func testTeacherDetail() {
		app.buttons["Login"].tap()
		let teacherCell = app.tables.children(matching: .cell).element(boundBy: 2).staticTexts["BI-PJS.1"]
		XCTAssert(teacherCell.waitForExistence(timeout: 7))
		teacherCell.tap()
		
		XCTAssert(app.tables.staticTexts.count > 0)

		let textField = app.tables/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"Janata Pavel")/*[[".cells.containing(.staticText, identifier:\"janatpa3\")",".cells.containing(.staticText, identifier:\"Janata Pavel\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .textField).element
		XCTAssert(textField.waitForExistence(timeout: 7))
		textField.tap()
		textField.clearText(andReplaceWith: "50")
		
		let saveButton = app.navigationBars.buttons["Save"]
		saveButton.tap()
		XCTAssert(app.tables["GroupTable"].staticTexts.count > 0)
	}

	func testTeacherStudent() {
		app.buttons["Login"].tap()
		let teacherCell = app.tables.children(matching: .cell).element(boundBy: 2).staticTexts["BI-PJS.1"]
		XCTAssert(teacherCell.waitForExistence(timeout: 7))
		teacherCell.tap()
		app/*@START_MENU_TOKEN@*/.buttons["Student"]/*[[".segmentedControls.buttons[\"Student\"]",".buttons[\"Student\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

		let tablesQuery = app.tables
		tablesQuery.staticTexts["Test 1"].tap()
		let textField = tablesQuery.cells.containing(.staticText, identifier:"Test 1").children(matching: .textField).element
		textField.tap()
		textField.clearText(andReplaceWith: "3")
		let saveButton = app.navigationBars.buttons["Save"]
		saveButton.tap()

		XCTAssert(app.tables["StudentTable"].staticTexts.count > 0)
	}
	
	func testChangeStudent() {
		app.buttons["Login"].tap()
		let teacherCell = app.tables.children(matching: .cell).element(boundBy: 2).staticTexts["BI-PJS.1"]
		XCTAssert(teacherCell.waitForExistence(timeout: 7))
		teacherCell.tap()
		app/*@START_MENU_TOKEN@*/.buttons["Student"]/*[[".segmentedControls.buttons[\"Student\"]",".buttons[\"Student\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
		
		let changeButton = app.tables.buttons["Change"]
		changeButton.tap()
		app.searchFields["Search student"].tap()
		app.tables.staticTexts["tichon"].tap()
		
		XCTAssert(app.tables.staticTexts["Ondřej Tichý"].waitForExistence(timeout: 5))
	}
	
	private func chooseSemester(_ semester: String, currentSemester: String) {
		app.buttons["Settings button"].tap()
		let picker = app.tables.staticTexts[currentSemester]
		XCTAssert(picker.waitForExistence(timeout: 7))
		picker.tap()
		app.pickers.pickerWheels[currentSemester].adjust(toPickerWheelValue: semester)
		app.toolbars["Toolbar"].buttons["Done"].tap()
		app.navigationBars["Settings"].buttons["Courses"].tap()
	}
}
