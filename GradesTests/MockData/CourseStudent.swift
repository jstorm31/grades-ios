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
		let parent1 = Classification(id: 1, text: [ClassificationText(identifier: "en", name: "Activity")], scope: nil, type: "ACTIVITY", valueType: .number, value: .number(4), parentId: nil, isHidden: false)
		let parent2 = Classification(id: 2, text: [ClassificationText(identifier: "en", name: "Exam")], scope: nil, type: "EXAM", valueType: .number, value: .number(20), parentId: nil, isHidden: false)
		
		let activity1 = Classification(id: 3, text: [ClassificationText(identifier: "en", name: "Lecture 1")], scope: nil, type: "ACTIVITY", valueType: .number, value: .number(1), parentId: 1, isHidden: false)
		let activity2 = Classification(id: 4, text: [ClassificationText(identifier: "en", name: "Lecture 2")], scope: nil, type: "ACTIVITY", valueType: .number, value: .number(2), parentId: 1, isHidden: false)
		let subActivity1 = Classification(id: 5, text: [ClassificationText(identifier: "en", name: "Lecture 2.1")], scope: nil, type: "ACTIVITY", valueType: .number, value: .number(1), parentId: 4, isHidden: false)
		
		let exam1 = Classification(id: 5, text: [ClassificationText(identifier: "en", name: "Exam test")], scope: nil, type: "TEST", valueType: .number, value: .number(20), parentId: 2, isHidden: false)
		let subExam1 = Classification(id: 6, text: [ClassificationText(identifier: "en", name: "Exam test - try 1")], scope: nil, type: "TEST", valueType: .number, value: .number(20), parentId: 5, isHidden: false)
		let subSubExam1 = Classification(id: 7, text: [ClassificationText(identifier: "en", name: "Exam test - try 2")], scope: nil, type: "TEST", valueType: .number, value: .number(20), parentId: 6, isHidden: false)
		
		return [parent1, activity1, parent2, activity2, exam1, subActivity1, subExam1, subSubExam1]
	}
}
