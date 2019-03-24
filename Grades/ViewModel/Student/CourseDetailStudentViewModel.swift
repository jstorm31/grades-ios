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

final class CourseDetailStudentViewModel: BaseViewModel {
    private let repository: CourseStudentRepositoryProtocol
    private let coordinator: SceneCoordinatorType
    private let bag = DisposeBag()

    let courseCode: String
    let courseName: String?
    let classifications = BehaviorRelay<[GroupedClassification]>(value: [])
    let totalPoints = BehaviorRelay<Double?>(value: nil)
    let totalGrade = BehaviorRelay<String?>(value: nil)
    let isFetching = BehaviorRelay<Bool>(value: false)
    let error = BehaviorSubject<Error?>(value: nil)
    var onBack: CocoaAction

    init(coordinator: SceneCoordinatorType, repository: CourseStudentRepositoryProtocol) {
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

        let allClassifications = repository.course.unwrap()
            .map { $0.classifications }
            .share()

        // Total points
        allClassifications
            .map { $0.first { $0.type == ClassificationType.pointsTotal.rawValue } ?? nil }
            .unwrap()
            .map { (item: Classification) -> Double? in
                guard let value = item.value else { return nil }

                switch value {
                case let .number(number):
                    return number
                default:
                    return nil
                }
            }
            .bind(to: totalPoints)
            .disposed(by: bag)

        // Final grade
        allClassifications
            .map { $0.first { $0.type == ClassificationType.finalScore.rawValue } ?? nil }
            .unwrap()
            .map { (item: Classification) -> String? in
                guard let value = item.value else { return nil }

                switch value {
                case let .string(string):
                    return string
                default:
                    return nil
                }
            }
            .bind(to: totalGrade)
            .disposed(by: bag)

        repository.bindOutput()
    }
}
