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

protocol TeacherClassificationViewModelProtocol {
    var course: TeacherCourse { get }
    var onBackAction: CocoaAction { get }

    func scene(forSegmentIndex index: Int) -> Scene?
}

final class TeacherClassificationViewModel: BaseViewModel, TeacherClassificationViewModelProtocol {
    // MARK: private properties

    private let coordinator: SceneCoordinatorType

    private lazy var groupClassificationScene: Scene = {
        let viewModel = GroupClassificationViewModel(dependencies: AppDependency.shared, course: course, user: user)
        return .groupClassification(viewModel)
    }()

    private lazy var studentClassificationScene: Scene = {
        let viewModel = StudentClassificationViewModel(
            dependencies: AppDependency.shared,
            coordinator: coordinator,
            course: course
        )
        return .studentClassification(viewModel)
    }()

    // MARK: public properties

    let course: TeacherCourse
    let user: User

    lazy var onBackAction = CocoaAction { [weak self] in
        self?.coordinator.didPop()
            .asObservable().map { _ in } ?? Observable.empty()
    }

    // MARK: initialization

    init(coordinator: SceneCoordinatorType, course: TeacherCourse, user: User) {
        self.coordinator = coordinator
        self.course = course
        self.user = user
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
