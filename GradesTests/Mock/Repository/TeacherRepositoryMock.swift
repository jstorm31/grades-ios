//
//  TeacherRepositoryMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 10/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import RxCocoa
@testable import Grades

final class TeacherRepositoryMock: TeacherRepositoryProtocol {
	var groups = BehaviorRelay<[StudentGroup]>(value: [])
	
	var classifications = BehaviorRelay<[Classification]>(value: [])
	
	var isLoading = BehaviorSubject<Bool>(value: false)
	var error = BehaviorSubject<Error?>(value: nil)
	
	func getGroupOptions(forCourse: String) {
		groups.accept([
			StudentGroup(id: "ALL", name: "ALL_STUDENTS", description: "All students"),
			StudentGroup(id: "PARALLEL_1", name: "PARALLEL_MONDAY", description: "Parallel monday"),
		])
	}
	
	func getClassificationOptions(forCourse: String) {
		classifications.accept([
			Classification(id: 1, identifier: "test_1", text: [ClassificationText(identifier: "cs", name: "Test 1")], evaluationType: .manual, type: "TEST", valueType: .number, value: .number(3.5), parentId: nil, isHidden: false),
			Classification(id: 2, identifier: "homework", text: [ClassificationText(identifier: "cs", name: "Homework")], evaluationType: .manual, type: "HOMEWORK", valueType: .string, value: .string("Good"), parentId: nil, isHidden: false)
		])
	}
	
	func studentClassifications(course: String, groupCode: String, classificationId: String) -> Observable<[StudentClassification]> {
		return Observable.just([
			StudentClassification(identifier: "item1", username: "novtom", value: .number(4.5)),
			StudentClassification(identifier: "item2", username: "kobljan", value: .number(1)),
			StudentClassification(identifier: "item3", username: "ivtjir", value: nil),
		]).delaySubscription(0.5, scheduler: MainScheduler.instance)
	}
}
