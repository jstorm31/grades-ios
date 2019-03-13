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
    lazy var course = BehaviorRelay<CourseStudent?>(value: nil)

    init(username: String, code: String, name: String?, gradesApi: GradesAPIProtocol) {
        self.code = code
        self.name = name
        self.gradesApi = gradesApi

        getCourseDetail(username: username, courseCode: code)
    }

    // MARK: methods

    /// Fetch course detail and student classification, merge and bind as CourseStudent
    private func getCourseDetail(username: String, courseCode: String) {
        gradesApi.getCourseStudentClassification(username: username, code: courseCode)
            .bind(to: course)
            .disposed(by: bag)
    }
}
