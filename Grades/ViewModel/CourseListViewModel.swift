//
//  SubjectList.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxSwift

struct CourseListViewModel {
    var user: Observable<User> {
        return GradesAPI.getUser()
    }

    var courses: Observable<[CourseGroup]> {
        let courses = GradesAPI.getCourses()
        let roles = GradesAPI.getRoles()

        let groupedCourses = Observable<[CourseGroup]>
            .zip(courses, roles) { courses, roles in

                // TODO: create util function and test it
                var groupedCourses: [CourseGroup] = [
                    CourseGroup(header: "Studuji"),
                    CourseGroup(header: "Učím"),
                ]

                // Map student courses
                for courseCode in roles.studentCourses {
                    if let course = courses.first(where: { $0.courseCode == courseCode }) {
                        groupedCourses[0].items.append(course)
                    }
                }

                // Map teacher courses
                for courseCode in roles.teacherCourses {
                    if let course = courses.first(where: { $0.courseCode == courseCode }) {
                        groupedCourses[1].items.append(course)
                    }
                }

                return groupedCourses
            }

        return groupedCourses
    }
}
