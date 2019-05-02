//
//  CourseStudentRepositoryMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 15/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import RxCocoa
@testable import GradesDev

final class CourseRepositoryMock: CourseRepositoryProtocol {
	var course: Course?
	var isFetching = BehaviorSubject<Bool>(value: false)
	var error = BehaviorSubject<Error?>(value: nil)
	
	var result = Result.success
	
	func set(course: Course) {
		self.course = course
	}
	
	func classifications(forStudent: String) -> Observable<[Classification]> {
		switch result {
		case .success:
			return Observable.just(CourseStudentMockData.classifications)
				.delaySubscription(1, scheduler: MainScheduler.instance)
		case .failure:
			return Observable.error(ApiError.general)
		}
	}
	
	func groupedClassifications(forStudent: String) -> Observable<[GroupedClassification]> {
		switch result {
		case .success:
			let classification = Classification(id: 2, identifier: "test-24", text: [], evaluationType: .manual, type: nil, valueType: .string, value: nil, parentId: nil, isHidden: false)
			return Observable.just([GroupedClassification(fromClassification: classification, items: CourseStudentMockData.classifications)])
				.delaySubscription(1, scheduler: MainScheduler.instance)
		case .failure:
			return Observable.error(ApiError.general)
		}
	}
	
	func overview(forStudent: String) -> Observable<StudentOverview> {
		switch result {
		case .success:
			return Observable.just((totalPoints: 64.0, finalGrade: "D"))
				.delaySubscription(1, scheduler: MainScheduler.instance)
		case .failure:
			return Observable.error(ApiError.general)
		}
	}
}
