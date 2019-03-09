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
    private let api: GradesAPIProtocol
    private let bag = DisposeBag()

    init(api: GradesAPIProtocol) {
        self.api = api
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
        let roles = api.getRoles()
        let courses = api.getUser() // TODO: store username in state
            .map { $0.username }
            .flatMap(api.getCourses)

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
