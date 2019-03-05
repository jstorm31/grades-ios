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

    var subjects: Observable<[CourseGroup]> {
        let subjects = GradesAPI.getCourses()
        let roles = GradesAPI.getRoles()

        let groupedSubjects = Observable<[CourseGroup]>
            .zip(subjects, roles) { _, roles in
                let groupedSubjects = [
                    CourseGroup(header: "Studuji"),
                    CourseGroup(header: "Učím"),
                ]

                for subjectCode in roles.studentCourses
            }
    }
}
