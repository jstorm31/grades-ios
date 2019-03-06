//
//  CourseListViewModelTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 06/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import GradesDev

class CourseListViewModelTests: XCTestCase {
	var viewModel: CourseListViewModel!
	let bag = DisposeBag()
	
	override func setUp() {
		viewModel = CourseListViewModel(api: GradesAPIMock())
	}
	
	override func tearDown() {
	}
	
	func testMapCoursesToRoles() {
		viewModel.courses.asObservable()
			.skip(1) // Skip initial value
			.subscribe(onNext: { groupedCourses in
				XCTAssertEqual(groupedCourses.count, 2, "has two groups of subjects")
				
				let firstGroup = groupedCourses[0]
				let dataMock = [
					Course(courseCode: "BI-PST", overviewItems: [
						OverviewItem(classificationType: "ASSESMENT", value: nil),
						OverviewItem(classificationType: "POINTS_TOTAL", value: nil)
						]),
					Course(courseCode: "BI-PPA", overviewItems: [
						OverviewItem(classificationType: "ASSESMENT", value: nil),
						OverviewItem(classificationType: "POINTS_TOTAL", value: nil)
						])
				]
				
				XCTAssertEqual(firstGroup.items.count, 2, "group has right number of courses")
				XCTAssertEqual(firstGroup.header, "Studying", "has right header name")
				XCTAssertTrue(firstGroup.items == dataMock)
				
			})
			.disposed(by: bag)
	}
	
}
