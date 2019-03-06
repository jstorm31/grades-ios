//
//  SubjectList.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxSwift

class CourseListViewModel {
    private let api: GradesAPIProtocol

    init(api: GradesAPIProtocol = GradesAPI.shared) {
        self.api = api
    }

    var user: Observable<User> {
        return api.getUser()
    }

    /// Returns courses grouped by role in sections
    func courses(sectionTitles: [String]) -> Observable<[CourseGroup]> {
        let courses = api.getCourses()
        let roles = api.getRoles()

        return Observable<[CourseGroup]>
            .zip(courses, roles) { [unowned self] in
                self.map(courses: $0, toRoles: $1)
                    .enumerated()
                    .map { offset, element in
                        CourseGroup(header: sectionTitles[offset], items: element)
                    }
            }
    }

    // MARK: methods

    /// Map course details to their roles
    private func map(courses: [Course], toRoles roles: UserRoles) -> [[Course]] {
        // Create array from roles struct and map courses details to correct role
        return [roles.studentCourses, roles.teacherCourses]
            .map { courseGroup in
                courseGroup.compactMap { courseCode in
                    courses.first(where: {
                        $0.courseCode == courseCode
                    })
                }
            }
            .filter { !$0.isEmpty }
    }
}
