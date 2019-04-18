//
//  StudentClassificationViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift

final class StudentClassificationViewModel {
    typealias Dependencies = HasGradesAPI

    private let dependencies: Dependencies
    private let coordinator: SceneCoordinatorType
    private let course: Course
    private let bag = DisposeBag()

    init(dependencies: Dependencies, coordinator: SceneCoordinatorType, course: Course) {
        self.dependencies = dependencies
        self.coordinator = coordinator
        self.course = course
    }

    func bindOutput() {
        dependencies.gradesApi.getTeacherStudents(courseCode: course.code)
            .subscribe(onNext: { Log.debug("\($0)") })
            .disposed(by: bag)
    }
}
