//
//  CourseStudent.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 15/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

@testable import GradesDev

struct CourseStudentMockData {
	static var classifications: [Classification] {
		let parent1 = Classification(id: 1, identifier: "test1", text: [ClassificationText(identifier: "en", name: "Activity")], evaluationType: .manual, type: "ACTIVITY", valueType: .number, value: .number(4), parentId: nil, isHidden: false)
		let parent2 = Classification(id: 2, identifier: "test2", text: [ClassificationText(identifier: "en", name: "Exam")], evaluationType: .manual, type: "EXAM", valueType: .number, value: .number(20), parentId: nil, isHidden: false)
		
		let activity1 = Classification(id: 3, identifier: "test3", text: [ClassificationText(identifier: "en", name: "Lecture 1")], evaluationType: .manual, type: "ACTIVITY", valueType: .number, value: .number(1), parentId: 1, isHidden: false)
		let activity2 = Classification(id: 4, identifier: "test4", text: [ClassificationText(identifier: "en", name: "Lecture 2")], evaluationType: .manual, type: "ACTIVITY", valueType: .number, value: .number(2), parentId: 1, isHidden: false)
		let subActivity1 = Classification(id: 5, identifier: "test5", text: [ClassificationText(identifier: "en", name: "Lecture 2.1")], evaluationType: .manual, type: "ACTIVITY", valueType: .number, value: .number(1), parentId: 4, isHidden: false)
		
		let exam1 = Classification(id: 5, identifier: "test6", text: [ClassificationText(identifier: "en", name: "Exam test")], evaluationType: .manual, type: "TEST", valueType: .number, value: .number(20), parentId: 2, isHidden: false)
		let subExam1 = Classification(id: 6, identifier: "test7", text: [ClassificationText(identifier: "en", name: "Exam test - try 1")], evaluationType: .manual, type: "TEST", valueType: .number, value: .number(20), parentId: 5, isHidden: false)
		let subSubExam1 = Classification(id: 7, identifier: "test8", text: [ClassificationText(identifier: "en", name: "Exam test - try 2")], evaluationType: .manual, type: "TEST", valueType: .number, value: .number(20), parentId: 6, isHidden: false)
		
		let totalPoints = Classification(id: 8, identifier: "test9", text: [ClassificationText(identifier: "en", name: "Total points")], evaluationType: .manual, type: ClassificationType.pointsTotal.rawValue, valueType: .number, value: .number(73.5), parentId: nil, isHidden: false)
		
		let finalGrade = Classification(id: 9, identifier: "test10", text: [ClassificationText(identifier: "en", name: "Final grade")], evaluationType: .manual, type: ClassificationType.finalScore.rawValue, valueType: .string, value: .string("B"), parentId: nil, isHidden: false)
		
		return [parent1, activity1, parent2, activity2, exam1, subActivity1, subExam1, subSubExam1, totalPoints, finalGrade]
	}
}
