//
//  AppDependency+Factories.swift
//  Grades
//
//  Created by Jiří Zdvomka on 12/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

extension AppDependency: HasCourseStudentRepositoryFactory {
    var courseStudentRepositoryFactory: CourseStudentRepositoryFactory {
        return { username, course in
            CourseStudentRepository(dependencies: self, username: username, course: course)
        }
    }
}
