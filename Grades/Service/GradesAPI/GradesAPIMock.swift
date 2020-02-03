//
//  GradesAPIMock.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/02/2020.
//  Copyright © 2020 jiri.zdovmka. All rights reserved.
//

// swiftlint:disable line_length

import RxSwift

final class GradesAPIMock: GradesAPIProtocol {
    let delay: RxTimeInterval = .milliseconds(200)

    init() {
        print("Initializing GradesAPIMock")
    }

    func getUser() -> Observable<User> {
        return Observable.just(User(id: 1, username: "testuser", firstName: "Test", lastName: "User")).delaySubscription(delay, scheduler: MainScheduler.asyncInstance)
    }

    func getTeacherCourses(username _: String) -> Observable<[TeacherCourse]> {
        return Observable.just([
            TeacherCourse(fromCourse: Course(code: "BI-ZMA", name: "Základy matematické analýzy")),
            TeacherCourse(fromCourse: Course(code: "BI-PST", name: "Pravděpodobnost a statistika"))
        ]).delaySubscription(delay, scheduler: MainScheduler.asyncInstance)
    }

    func getStudentCourses(username _: String) -> Observable<[StudentCourse]> {
        return Observable.just([
            StudentCourse(code: "BI-PJS", name: "Programování v Javascriptu", finalValue: .string("C")),
            StudentCourse(code: "BI-IOS", name: "Základy programování pro iOS", finalValue: .number(35.0))
        ]).delaySubscription(delay, scheduler: MainScheduler.asyncInstance)
    }

    func getCourse(code _: String) -> Observable<Course> {
        return Observable.just(Course(code: "BI-PJS", name: "Programování v Javascriptu")).delaySubscription(delay, scheduler: MainScheduler.asyncInstance)
    }

    func getCourseStudentClassification(username _: String, code _: String) -> Observable<[Classification]> {
        return Observable.just(GradesAPIMock.classifications).delaySubscription(delay, scheduler: MainScheduler.asyncInstance)
    }

    func getCurrentSemestrCode() -> Observable<String> {
        return Observable.just("B182").delaySubscription(delay, scheduler: MainScheduler.asyncInstance)
    }

    func getStudentGroups(forCourse _: String, username _: String?) -> Observable<[StudentGroup]> {
        return Observable.just([
            StudentGroup(id: "A145", name: "Cvičení 1", description: "Cvič 1"),
            StudentGroup(id: "A146", name: "Cvičení 2", description: "Cvič 2")
        ]).delaySubscription(delay, scheduler: MainScheduler.asyncInstance)
    }

    func getClassifications(forCourse _: String) -> Observable<[Classification]> {
        return Observable.just([
            Classification(id: 1, identifier: "test_1", text: [ClassificationText(identifier: "cs", name: "Test 1")], evaluationType: .manual, type: "TEST", valueType: .number, value: .number(3.5), parentId: nil, isHidden: false),
            Classification(id: 2, identifier: "homework", text: [ClassificationText(identifier: "cs", name: "Homework")], evaluationType: .manual, type: "HOMEWORK", valueType: .bool, value: .bool(true), parentId: nil, isHidden: false)
        ]).delaySubscription(delay, scheduler: MainScheduler.asyncInstance)
    }

    func getGroupClassifications(courseCode _: String, groupCode _: String, classificationId _: String) -> Observable<[StudentClassification]> {
        return Observable.just([
            StudentClassification(ident: "item1", firstName: "Tomáš", lastName: "Novák", username: "novtom", value: .number(13.5)),
            StudentClassification(ident: "item2", firstName: "Jan", lastName: "Kobl", username: "kobljan", value: .number(4.0)),
            StudentClassification(ident: "item3", firstName: "Jiří", lastName: "Ivan", username: "ivtjir", value: .number(1))
        ]).delaySubscription(delay, scheduler: MainScheduler.asyncInstance)
    }

    func getTeacherStudents(courseCode _: String) -> Observable<[User]> {
        return Observable.just([
            User(id: 1, username: "kucerj48", firstName: "Jan", lastName: "Kučera"),
            User(id: 2, username: "janatpa3", firstName: "Pavel", lastName: "Janata"),
            User(id: 3, username: "ottastep", firstName: "Štěpán", lastName: "Otta")
        ]).delaySubscription(delay, scheduler: MainScheduler.asyncInstance)
    }

    func getNewNotifications(forUser _: String) -> Observable<Notifications> {
        return Observable.just(Notifications(notifications: [
            PushNotification(id: 1, courseCode: "BI-PJS", texts: [NotificationText(identifier: "test", title: "Test evaluation", text: "Test result 10 points")], url: nil, badgeCount: 1)
        ])).delaySubscription(delay, scheduler: MainScheduler.asyncInstance)
    }

    func putStudentsClassifications(courseCode _: String, data _: [StudentClassification], notify _: Bool) -> Observable<Void> {
        return Observable.empty().delaySubscription(delay, scheduler: MainScheduler.asyncInstance)
    }

    func markNotificationRead(username _: String, notificationId _: Int) -> Observable<Void> {
        return Observable.empty().delaySubscription(delay, scheduler: MainScheduler.asyncInstance)
    }
}

// MARK: Data

extension GradesAPIMock {
    static var classifications: [Classification] {
        let parent1 = Classification(id: 1, identifier: "test1", text: [ClassificationText(identifier: "en", name: "Activity")], evaluationType: .manual, type: "ACTIVITY", valueType: .number, value: .number(4), parentId: nil, isHidden: false)
        let parent2 = Classification(id: 2, identifier: "test2", text: [ClassificationText(identifier: "en", name: "Exam")], evaluationType: .aggregation, type: "EXAM", valueType: .number, value: .number(20), parentId: nil, isHidden: false)

        let activity1 = Classification(id: 3, identifier: "test3", text: [ClassificationText(identifier: "en", name: "Lecture 1")], evaluationType: .manual, type: "ACTIVITY", valueType: .number, value: .number(1), parentId: 1, isHidden: false)
        let activity2 = Classification(id: 4, identifier: "test4", text: [ClassificationText(identifier: "en", name: "Lecture 2")], evaluationType: .manual, type: "ACTIVITY", valueType: .number, value: .number(2), parentId: 1, isHidden: true)
        let subActivity1 = Classification(id: 5, identifier: "test5", text: [ClassificationText(identifier: "en", name: "Lecture 2.1")], evaluationType: .manual, type: "ACTIVITY", valueType: .number, value: nil, parentId: 4, isHidden: false)

        let exam1 = Classification(id: 24, identifier: "test6", text: [ClassificationText(identifier: "en", name: "Exam test")], evaluationType: .manual, type: "TEST", valueType: .number, value: .number(20), parentId: 2, isHidden: false)
        let subExam1 = Classification(id: 6, identifier: "test7", text: [ClassificationText(identifier: "en", name: "Exam test - try 1")], evaluationType: .manual, type: "TEST", valueType: .number, value: .number(20), parentId: 24, isHidden: false)
        let subSubExam1 = Classification(id: 7, identifier: "test8", text: [ClassificationText(identifier: "en", name: "Exam test - try 2")], evaluationType: .manual, type: "TEST", valueType: .number, value: .number(20), parentId: 6, isHidden: false)

        let totalPoints = Classification(id: 8, identifier: "test9", text: [ClassificationText(identifier: "en", name: "Total points")], evaluationType: .manual, type: ClassificationType.pointsTotal.rawValue, valueType: .number, value: .number(73.5), parentId: nil, isHidden: false)

        let finalGrade = Classification(id: 9, identifier: "test10", text: [ClassificationText(identifier: "en", name: "Final grade")], evaluationType: .manual, type: ClassificationType.finalScore.rawValue, valueType: .string, value: .string("B"), parentId: nil, isHidden: false)

        return [parent1, activity1, parent2, activity2, exam1, subActivity1, subExam1, subSubExam1, totalPoints, finalGrade]
    }
}
