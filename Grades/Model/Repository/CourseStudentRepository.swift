//
//  CourseRepository.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift

protocol CourseStudentRepositoryProtocol {
    var course: BehaviorRelay<CourseStudent?> { get }
}

class CourseStudentRepository: CourseStudentRepositoryProtocol {
    private let gradesApi: GradesAPIProtocol
    private let bag = DisposeBag()

    let code: String
    let name: String?
    var course = BehaviorRelay<CourseStudent?>(value: nil)
    lazy var error = BehaviorSubject<Error?>(value: nil)

    init(username: String, code: String, name: String?, gradesApi: GradesAPIProtocol) {
        self.code = code
        self.name = name
        self.gradesApi = gradesApi

        getCourseDetail(username: username, courseCode: code)
    }

    // MARK: methods

    /// Fetch course detail and student classification, merge and bind as CourseStudent
    private func getCourseDetail(username: String, courseCode: String) {
        let coursesSubscription = gradesApi.getCourseStudentClassification(username: username, code: courseCode).share()

        coursesSubscription
            .bind(to: course)
            .disposed(by: bag)

        coursesSubscription
            .monitorLoading()
            .errors()
            .bind(to: error)
            .disposed(by: bag)
    }
}
