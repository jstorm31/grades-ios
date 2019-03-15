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
    let isFetching = BehaviorRelay<Bool>(value: false)
    let error = BehaviorSubject<Error?>(value: nil)
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
    }

    func bindOutput() {
        repository.groupedClassifications
            .map {
                $0.filter {
                    $0.type != ClassificationType.pointsTotal.rawValue && $0.type != ClassificationType.finalScore.rawValue
                }
            }
            .bind(to: classifications)
            .disposed(by: bag)

        repository.isFetching.bind(to: isFetching).disposed(by: bag)
        repository.error.bind(to: error).disposed(by: bag)

        repository.bindOutput()
    }
}
