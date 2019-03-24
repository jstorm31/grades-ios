//
//  TeacherClassificationViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxCocoa
import RxSwift

protocol TeacherClassificationViewModelProtocol {
    var course: TeacherCourse { get }
    var onBackAction: CocoaAction { get }
}

class TeacherClassificationViewModel: BaseViewModel, TeacherClassificationViewModelProtocol {
    let coordinator: SceneCoordinatorType
    let course: TeacherCourse

    lazy var onBackAction = CocoaAction { [weak self] in
        self?.coordinator.didPop()
            .asObservable().map { _ in } ?? Observable.empty()
    }

    init(coordinator: SceneCoordinatorType, course: TeacherCourse) {
        self.coordinator = coordinator
        self.course = course
    }
}
