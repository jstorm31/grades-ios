//
//  HttpServiceTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 24/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
@testable import GradesDev

class HttpServiceTests: XCTestCase {
	var httpService: HttpService!
	let client = AppDependencyMock.shared._authService.client as! AuthClientMock

    override func setUp() {
		httpService = HttpService(dependencies: AppDependencyMock.shared)
    }

	func testRenewAccesstoken() {
		client.result = .expires
		httpService.get(url: URL(string: "http://test.com")!)
	}
}
