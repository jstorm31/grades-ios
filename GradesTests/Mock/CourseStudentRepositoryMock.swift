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

class CourseStudentRepositoryMock: CourseStudentRepositoryProtocol {
	private let bag = DisposeBag()
	var emitError = false
	
	let code: String
	let username: String
	var name: String?
	let gradesApi: GradesAPIProtocol
	
	let course = BehaviorRelay<CourseStudent?>(value: nil)
	let groupedClassifications = BehaviorSubject<[GroupedClassification]>(value: [])
	let isFetching = BehaviorSubject<Bool>(value: false)
	let error = BehaviorSubject<Error?>(value: nil)

	init(gradesApi: GradesAPIProtocol = GradesAPIMock(), username: String = "mockuser", code: String = "BI-PPA", name: String? = nil) {
		self.code = code
		self.username = username
		self.name = name
		self.gradesApi = gradesApi
	}
	
	
	func bindOutput() {
		course.accept(CourseStudent(classifications: CourseStudentMockData.classifications))
		
		let classification = Classification(id: 2, text: [], scope: nil, type: nil, valueType: .string, value: nil, parentId: nil, isHidden: false)
		groupedClassifications.onNext(
			[GroupedClassification(fromClassification: classification, items: CourseStudentMockData.classifications)]
		)
		
		isFetching.onNext(true)
		Observable.zip(Observable.just(false), Observable<Int>.interval(RxTimeInterval(1), scheduler: MainScheduler.instance)) { bool, index in
			bool
		}
		.subscribe(onNext: { [weak self] value in
			self?.isFetching.onNext(value)
		})
		.disposed(by: bag)
		
		isFetching.onNext(true)
		
		isFetching.onNext(false)
		
		error.onNext(emitError ? ApiError.general : nil)
	}
}
