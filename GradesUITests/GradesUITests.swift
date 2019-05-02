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

    override func setUp() {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
		
		dynamicStubs.setUp()

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
		app.launchArguments = ["--stub-authentication"]
		app.launch()		

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
		dynamicStubs.tearDown()
	}

    func testLoginScreen() {
		XCTAssertTrue(app.otherElements.containing(.image, identifier:"FullTextLogo").element.exists)
		
		app.buttons["Login"].tap()

		
		
//		let webViewTitle = app.webViews/*@START_MENU_TOKEN@*/.staticTexts["Authorization Server of CTU in Prague"]/*[[".otherElements[\"Authorization Server of CTU :: Login\"]",".otherElements[\"banner\"]",".otherElements[\"Authorization Server of CTU in Prague\"]",".staticTexts[\"1\"]",".staticTexts[\"Authorization Server of CTU in Prague\"]"],[[[-1,4],[-1,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,4],[-1,3],[-1,2,3],[-1,1,2]],[[-1,4],[-1,3],[-1,2,3]],[[-1,4],[-1,3]]],[0]]@END_MENU_TOKEN@*/
//		let exists = NSPredicate(format: "exists == 1")
//		expectation(for: exists, evaluatedWith: webViewTitle, handler: nil)
//
//		waitForExpectations(timeout: 5, handler: nil)
//		XCTAssert(webViewTitle.exists)
    }

}
