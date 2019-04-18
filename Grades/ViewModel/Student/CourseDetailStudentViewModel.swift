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
    typealias Dependencies = HasCourseRepository

    // MARK: Properties

    let classifications = BehaviorRelay<[GroupedClassification]>(value: [])
    let totalPoints = BehaviorSubject<Double?>(value: nil)
    let finalGrade = BehaviorSubject<String?>(value: nil)
    let isFetching = BehaviorSubject<Bool>(value: false)
    let error = BehaviorSubject<Error?>(value: nil)
    var onBack: CocoaAction

    var courseCode: String {
        return dependencies.courseRepository.course?.code ?? ""
    }

    var courseName: String? {
        return dependencies.courseRepository.course?.name
    }

    private let dependencies: Dependencies
    private let repository: CourseRepositoryProtocol
    private let coordinator: SceneCoordinatorType
    private let bag = DisposeBag()
    private let studentUsername: String

    // MARK: Initialization

    init(dependencies: Dependencies, coordinator: SceneCoordinatorType, course: Course, username: String) {
        self.coordinator = coordinator
        self.dependencies = dependencies
        studentUsername = username
        repository = dependencies.courseRepository
        repository.set(course: course)

        onBack = CocoaAction {
            coordinator.didPop().asObservable().map { _ in }
        }

        super.init()
    }

    // MARK: Binding

    func bindOutput() {
        repository.groupedClassifications(forStudent: studentUsername)
            .map {
                $0.filter {
                    $0.type != ClassificationType.pointsTotal.rawValue && $0.type != ClassificationType.finalScore.rawValue
                }
            }
            .bind(to: classifications)
            .disposed(by: bag)

        repository.isFetching.bind(to: isFetching).disposed(by: bag)
        repository.error.bind(to: error).disposed(by: bag)

        let overview = repository.overview(forStudent: studentUsername).share(replay: 1, scope: .whileConnected)
        overview.map({ $0.totalPoints }).bind(to: totalPoints).disposed(by: bag)
        overview.map({ $0.finalGrade }).bind(to: finalGrade).disposed(by: bag)
    }
}
