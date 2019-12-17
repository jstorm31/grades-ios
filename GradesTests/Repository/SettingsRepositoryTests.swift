//
//  SettingsRepositoryTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 10/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
@testable import Grades

class SettingsRepositoryTests: XCTestCase {
	var scheduler: ConcurrentDispatchQueueScheduler!
	var repository: SettingsRepositoryProtocol!

    override func setUp() {
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        repository = SettingsRepository(dependencies: AppDependencyMock.shared)
    }
	
	func testSemesterOptions() {
		let options = repository.fetchCurrentSemester()
			.flatMap { _ -> Observable<[String]> in
				self.repository.semesterOptions.asObservable()
			}
			.subscribeOn(scheduler)
		
		let result = try! options.toBlocking(timeout: 2).first()!
		XCTAssertEqual(result.count, 8)
	}
}
