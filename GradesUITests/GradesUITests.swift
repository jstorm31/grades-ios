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
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
		
		dynamicStubs.setUp()

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
		app.launchArguments = ["--stub-authentication", "--ui-testing"]
		app.launch()		

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
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

		waitForExpectations(timeout: 5, handler: nil)
		XCTAssert(jsCell.exists)
		XCTAssert(iosCell.exists)
    }
	
	func testSemesterChange() {
		app.buttons["Login"].tap()
	    app.buttons["Settings button"].tap()
		app.tables.staticTexts["B182"].tap()
		app.pickers.pickerWheels["B182"].adjust(toPickerWheelValue: "B181")
		app.toolbars["Toolbar"].buttons["Done"].tap()
		app.navigationBars["Settings"].buttons["Courses"].tap()
		
		let jsCell = app.staticTexts["BI-PJS.1"]
		let komCell = app.staticTexts["BI-KOM"]

		expectation(for: doesNotExist, evaluatedWith: jsCell, handler: nil)
		expectation(for: exists, evaluatedWith: komCell, handler: nil)

		waitForExpectations(timeout: 5, handler: nil)
		XCTAssertFalse(jsCell.exists)
		XCTAssert(komCell.exists)
	}

}
