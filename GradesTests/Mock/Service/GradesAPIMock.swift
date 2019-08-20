//
//  File.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 06/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
@testable import GradesDev

class GradesAPIMock: GradesAPIProtocol {
	// MARK: mock data with default values
	var result = Result.success
	
	static var userInfo = User(id: 14, username: "mockuser", firstName: "Ondřej", lastName: "Krátký")
	
	private let courses = [
		StudentCourse(code: "BI-PPA", finalValue: .number(4)),
		StudentCourse(code: "BI-ZMA", finalValue: .string("C")),
		TeacherCourse(code: "MI-IOS"),
		TeacherCourse(code: "BI-PST")
	]
	
	
	// MARK: methods
	
	func getUser() -> Observable<User> {
		switch result {
		case .success:
			return Observable.just(GradesAPIMock.userInfo)
		case .failure:
			return Observable.error(ApiError.general)
		}
	}
	
	func getCourses(username _: String) -> Observable<[Course]> {
		switch result {
		case .success:
			return Observable.just(courses)
		case .failure:
			return Observable.error(ApiError.general)
		}
	}
	
	func getCourse(code: String) -> Observable<Course> {
		return Observable.just(Course(code: code, name: "Programming paradigmas"))
	}
	
	func getCourseStudentClassification(username: String, code: String) -> Observable<[Classification]> {
		switch result {
		case .success:
			return Observable.just(CourseStudentMockData.classifications)
		case .failure:
			return Observable.error(ApiError.general)
		}
	}
	
	func getTeacherCourses(username: String) -> Observable<[TeacherCourse]> {
		switch result {
		case .success:
			return Observable.just([
				TeacherCourse(code: "BI-IOS"),
				TeacherCourse(code: "BI-OOP")
				])
		case .failure:
			return Observable.error(ApiError.general)
		}
	}
	
	func getStudentCourses(username: String) -> Observable<[StudentCourse]> {
		switch result {
		case .success:
			return Observable.just([
				StudentCourse(code: "MI-IOS", finalValue: .number(45)),
				StudentCourse(code: "BI-ZMA", finalValue: .bool(false))
				])
		case .failure:
			return Observable.error(ApiError.general)
		}
	}
	
	func getCurrentSemestrCode() -> Observable<String> {
		return Observable.just("B182")
	}
	
	func getStudentGroups(forCourse course: String, username: String?) -> Observable<[StudentGroup]> {
		switch result {
		case .success:
			return Observable.just([
				StudentGroup(id: "A145", name: "Cvičení 1", description: "Cvič 1"),
				StudentGroup(id: "A146", name: "Cvičení 2", description: "Cvič 2")
			]).delaySubscription(0.5, scheduler: MainScheduler.instance)
		case .failure:
			return Observable.error(ApiError.general)
		}
	}
	
	func getClassifications(forCourse: String) -> Observable<[Classification]> {
		switch result {
		case .success:
			return Observable.just([
				Classification(id: 1, identifier: "test_1", text: [ClassificationText(identifier: "cs", name: "Test 1")], evaluationType: .manual, type: "TEST", valueType: .number, value: .number(3.5), parentId: nil, isHidden: false),
				Classification(id: 2, identifier: "homework", text: [ClassificationText(identifier: "cs", name: "Homework")], evaluationType: .manual, type: "HOMEWORK", valueType: .string, value: .string("Good"), parentId: nil, isHidden: false)
				]).delaySubscription(0.5, scheduler: MainScheduler.instance)
		case .failure:
			return Observable.error(ApiError.general)
		}
	}
	
	func getGroupClassifications(courseCode: String, groupCode: String, classificationId: String) -> Observable<[StudentClassification]> {
		switch result {
		case .success:
			return Observable.just([
				StudentClassification(identifier: "item1", username: "novtom", value: .number(4.5)),
				StudentClassification(identifier: "item2", username: "kobljan", value: .number(1)),
				StudentClassification(identifier: "item3", username: "ivtjir", value: nil)
			]).delaySubscription(0.5, scheduler: MainScheduler.instance)
		case .failure:
			return Observable.error(ApiError.general)
		}
	}
	
	func getTeacherStudents(courseCode: String) -> Observable<[User]> {
		switch result {
		case .success:
			return Observable.just([
				User(id: 1, username: "kucerj48", firstName: "Jan", lastName: "Kučera"),
				User(id: 2, username: "janatpa3", firstName: "Pavel", lastName: "Janata"),
				User(id: 3, username: "ottastep", firstName: "Štěpán", lastName: "Otta")
			]).delaySubscription(0.5, scheduler: MainScheduler.instance)
		case .failure:
			return Observable.error(ApiError.general).delaySubscription(0.5, scheduler: MainScheduler.instance)
		}
	}
	
	func putStudentsClassifications(courseCode: String, data: [StudentClassification]) -> Observable<Void> {
		switch result {
		case .success:
			return Observable.empty().delaySubscription(0.5, scheduler: MainScheduler.instance)
		case .failure:
			return Observable.error(ApiError.general).delaySubscription(0.5, scheduler: MainScheduler.instance)
		}
	}
	
	func markNotificationRead(username: String, notificationId: Int) -> Observable<Void> {
		fatalError("markNotificationRead not implemented")
	}
}
