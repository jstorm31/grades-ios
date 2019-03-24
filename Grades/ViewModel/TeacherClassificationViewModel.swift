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
    var currentScene: Scene? { get set }
    var onBackAction: CocoaAction { get }

    func scene(forSegmentIndex index: Int) -> Scene?
}

final class TeacherClassificationViewModel: BaseViewModel, TeacherClassificationViewModelProtocol {
    // MARK: properties

    private let coordinator: SceneCoordinatorType

    private lazy var groupClassificationScene: Scene = {
        let viewModel = GroupClassificationViewModel()
        return .groupClassification(viewModel)
    }()

    var currentScene: Scene?
    let course: TeacherCourse

    lazy var onBackAction = CocoaAction { [weak self] in
        self?.coordinator.didPop()
            .asObservable().map { _ in } ?? Observable.empty()
    }

    // MARK: initialization

    init(coordinator: SceneCoordinatorType, course: TeacherCourse) {
        self.coordinator = coordinator
        self.course = course
    }

    // MARK: methods

    func scene(forSegmentIndex index: Int) -> Scene? {
        switch index {
        case TeacherSceneIndex.groupClassification.rawValue:
            return groupClassificationScene
        default:
            return nil
        }
    }
}
