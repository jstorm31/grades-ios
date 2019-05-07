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
	var scheduler: ConcurrentDispatchQueueScheduler!
	var httpService: HttpService!
	let client = AppDependencyMock.shared._authService.client as! AuthClientMock

    override func setUp() {
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		httpService = HttpService(dependencies: AppDependencyMock.shared)
    }

	func testRenewAccesstoken() {
		client.result = .expires
		
		let request = httpService.get(url: URL(string: "http://test.com")!).subscribeOn(scheduler)
		
		let result = try! request.toBlocking(timeout: 2).first()
		XCTAssertEqual(result, "test")
		XCTAssertEqual(client.called, 2)
	}
}
