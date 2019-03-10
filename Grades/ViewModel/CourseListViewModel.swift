//
//  SubjectList.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class CourseListViewModel {
    private let gradesApi: GradesAPIProtocol
    private let kosApi: KosApiProtocol
    private let bag = DisposeBag()
    private let user: UserInfo

    init(gradesApi: GradesAPIProtocol, kosApi: KosApiProtocol, user: UserInfo) {
        self.gradesApi = gradesApi
        self.kosApi = kosApi
        self.user = user
    }

    // MARK: output

    let courses = BehaviorRelay<[CourseGroup]>(value: [])
    let coursesError = BehaviorRelay<Error?>(value: nil)

    // MARK: methods

    func bindOutput() {
        getCourses()
            .catchError { [weak self] error in
                if let `self` = self {
                    Observable.just(error).bind(to: self.coursesError).disposed(by: self.bag)
                }

                return Observable.just([])
            }
            .bind(to: courses)
            .disposed(by: bag)
    }

    /// Fetches courses from api and transforms them to right format
    private func getCourses() -> Observable<[CourseGroup]> {
        let roles = gradesApi.getRoles()

        // Fetch courses and for each one, fetch his full name from kosApi
        let courses = gradesApi
            .getCourses(username: user.username)
            .map { courses in
                courses.map { [weak self] (course: Course) -> Course in
                    guard let `self` = self else { return course }

                    var courseWithName = Course(fromCourse: course)
                    self.kosApi.getCourseName(code: course.code)
                        .subscribe(onNext: { name in
                            Log.debug("Name fetched: \(name)")
                            courseWithName.name = name
                        })
                        .disposed(by: self.bag)
                    Log.debug("Course returned: \(courseWithName.code)")
                    return courseWithName
                }
            }

        return Observable<[CourseGroup]>
            .zip(courses, roles) { [unowned self] courses, roles in
                let sectionTitles = [L10n.Courses.studying, L10n.Courses.teaching]

                return self.map(courses: courses, toRoles: roles)
                    .enumerated()
                    .map { offset, element in
                        CourseGroup(header: sectionTitles[offset], items: element)
                    }
            }
    }

    /// Map course details to their roles
    private func map(courses: [Course], toRoles roles: UserRoles) -> [[Course]] {
        // Create array from roles struct and map courses details to correct role
        return [roles.studentCourses, roles.teacherCourses]
            .map { courseGroup in
                courseGroup.compactMap { code in
                    courses.first(where: {
                        $0.code == code
                    })
                }
            }
            .filter { !$0.isEmpty }
    }
}
