//
//  CoursesRepository.swift
//  Grades
//
//  Created by Jiří Zdvomka on 23/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift

protocol HasCoursesRepository {
    var coursesRepository: CoursesRepositoryProtocol { get }
}

protocol CoursesRepositoryProtocol {
    var userCourses: BehaviorRelay<CoursesByRoles> { get }
    var isFetching: BehaviorSubject<Bool> { get }
    var error: BehaviorSubject<Error?> { get }

    func getUserCourses(username: String)
}

final class CoursesRepository: CoursesRepositoryProtocol {
    typealias Dependencies = HasGradesAPI

    private let dependencies: Dependencies
    private let activityIndicator = ActivityIndicator()
    private let bag = DisposeBag()

    // MARK: output

    var userCourses = BehaviorRelay<CoursesByRoles>(value: CoursesByRoles(student: [], teacher: []))
    var isFetching = BehaviorSubject<Bool>(value: false)
    var error = BehaviorSubject<Error?>(value: nil)

    // MARK: initialization

    init(dependencies: Dependencies = AppDependency.shared) {
        self.dependencies = dependencies

        activityIndicator
            .distinctUntilChanged()
            .asObservable()
            .bind(to: isFetching)
            .disposed(by: bag)
    }

    // MARK: methods

    func getUserCourses(username: String) {
        let studentCourses = dependencies.gradesApi.getStudentCourses(username: username)
            .flatMap { [weak self] courses in
                Observable.from(courses).flatMap { [weak self] (studentCourse: StudentCourse) -> Observable<StudentCourse> in
                    self?.dependencies.gradesApi.getCourse(code: studentCourse.code)
                        .map { (course: Course) -> StudentCourse in
                            let courseWithName = StudentCourse(fromCourse: studentCourse)
                            courseWithName.name = course.name
                            return courseWithName
                        } ?? Observable.just(studentCourse)
                }.toArray()
            }
            .map { $0.sorted(by: { $0.code < $1.code }) }

        let teacherCourses = dependencies.gradesApi.getTeacherCourses(username: username)
            .flatMap { [weak self] courses in
                Observable.from(courses).flatMap { [weak self] course in
                    self?.dependencies.gradesApi.getCourse(code: course.code)
                        .map { TeacherCourse(fromCourse: $0) } ?? Observable.empty()
                }.toArray()
            }
            .map { $0.sorted(by: { $0.code < $1.code }) }

        Observable.zip(studentCourses, teacherCourses) { (studentCourses: [StudentCourse], teacherCourses: [TeacherCourse]) -> CoursesByRoles in
            CoursesByRoles(student: studentCourses, teacher: teacherCourses)
        }
        .trackActivity(activityIndicator)
        .catchError { [weak self] error in
            if let self = self {
                Observable.just(error).bind(to: self.error).disposed(by: self.bag)
            }

            return Observable.just(CoursesByRoles(student: [], teacher: []))
        }
        .bind(to: userCourses)
        .disposed(by: bag)
    }
}
