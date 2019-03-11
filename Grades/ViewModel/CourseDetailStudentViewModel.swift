//
//  CourseDetailStudentViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 11/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxSwift

struct CourseDetailStudentViewModel {
    var course: Course
    let coordinator: SceneCoordinatorType

    let onBack: CocoaAction

    init(course: Course, coordinator: SceneCoordinatorType) {
        self.course = course
        self.coordinator = coordinator

        onBack = CocoaAction {
            coordinator.didPop()
                .asObservable().map { _ in }
        }
    }
}
