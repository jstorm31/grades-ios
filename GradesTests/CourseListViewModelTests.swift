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
		viewModel.courses(sectionTitles: ["Studying", "Teaching"])
			.subscribe(onNext: { groupedCourses in
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
					
				XCTAssertEqual(groupedCourses.count, 2, "has two groups of subjects")
				XCTAssertEqual(firstGroup.items.count, 2, "group has right number of courses")
				XCTAssertEqual(firstGroup.header, "Studying", "has right header name")
				XCTAssertEqual(firstGroup.items == dataMock, true)
				
			})
			.disposed(by: bag)
	}
	
}
