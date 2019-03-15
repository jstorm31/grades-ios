//
//  CourseDetailStudentViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 11/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxCocoa
import RxSwift

class CourseDetailStudentViewModel: BaseViewModel {
    private let repository: CourseStudentRepository
    private let coordinator: SceneCoordinatorType
    private let bag = DisposeBag()

    let courseCode: String
    let courseName: String?
    let classifications = BehaviorRelay<[GroupedClassification]>(value: [])
    let error = BehaviorSubject<Error?>(value: nil)
    let isLoading = PublishSubject<Bool>()

    var onBack: CocoaAction

    init(coordinator: SceneCoordinatorType, repository: CourseStudentRepository) {
        self.coordinator = coordinator
        self.repository = repository
        courseCode = repository.code
        courseName = repository.name

        onBack = CocoaAction {
            coordinator.didPop()
                .asObservable().map { _ in }
        }

        super.init()
        bindOutput()
    }

    private func bindOutput() {
        let classification = repository.groupedClassifications.asObservable().share()

        classification
            .bind(to: classifications)
            .disposed(by: bag)

        classification
            .monitorLoading()
            .loading()
            .bind(to: isLoading)
            .disposed(by: bag)

        repository.error
            .bind(to: error)
            .disposed(by: bag)
    }
}
