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

enum TeacherSceneIndex: Int {
    case groupClassification = 0
    case studentClassification = 1
}

final class TeacherClassificationViewModel: BaseViewModel {
    typealias Dependencies = HasSceneCoordinator

    // MARK: private properties

    private let dependencies: Dependencies

    private lazy var groupClassificationScene: Scene = {
        let viewModel = GroupClassificationViewModel(dependencies: AppDependency.shared, course: course)
        return .groupClassification(viewModel)
    }()

    private lazy var studentClassificationScene: Scene = {
        let viewModel = StudentClassificationViewModel(dependencies: AppDependency.shared, course: course)
        return .studentClassification(viewModel)
    }()

    // MARK: public properties

    let defaultScene = TeacherSceneIndex.groupClassification
    let course: TeacherCourse

    lazy var onBackAction = CocoaAction { [weak self] in
        self?.dependencies.coordinator.didPop()
            .asObservable().map { _ in } ?? Observable.empty()
    }

    // MARK: initialization

    init(dependencies: Dependencies, course: TeacherCourse) {
        self.dependencies = dependencies
        self.course = course
    }

    // MARK: methods

    func scene(forSegmentIndex index: Int) -> Scene? {
        switch index {
        case TeacherSceneIndex.groupClassification.rawValue:
            return groupClassificationScene
        case TeacherSceneIndex.studentClassification.rawValue:
            return studentClassificationScene
        default:
            return nil
        }
    }
}
