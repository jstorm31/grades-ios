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
    typealias Dependencies = HasCourseRepository & HasUserRepository

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
    private let coordinator: SceneCoordinatorType
    private let bag = DisposeBag()

    // MARK: Initialization

    init(dependencies: Dependencies, coordinator: SceneCoordinatorType, course: Course) {
        self.coordinator = coordinator
        self.dependencies = dependencies
        dependencies.courseRepository.set(course: course)

        onBack = CocoaAction {
            coordinator.didPop().asObservable().map { _ in }
        }

        super.init()
    }

    // MARK: Binding

    func bindOutput() {
        let user = dependencies.userRepository.user.asObservable().unwrap().share(replay: 2, scope: .whileConnected)

        user.flatMap { [weak self] user in
            self?.dependencies.courseRepository.groupedClassifications(forStudent: user.username) ?? Observable.empty()
        }
        .map { groups in
            groups.map { group in
                let items = group.items.filter {
                    !$0.isHidden
                        && $0.type != ClassificationType.pointsTotal.rawValue
                        && $0.type != ClassificationType.finalScore.rawValue
                }
                return GroupedClassification(original: group, items: items)
            }
        }
        .bind(to: classifications)
        .disposed(by: bag)

        dependencies.courseRepository.isFetching.bind(to: isFetching).disposed(by: bag)
        dependencies.courseRepository.error.bind(to: error).disposed(by: bag)

        let overview = user
            .flatMap { [weak self] user in
                self?.dependencies.courseRepository.overview(forStudent: user.username) ?? Observable.empty()
            }
            .share()

        overview.map({ $0.totalPoints }).bind(to: totalPoints).disposed(by: bag)
        overview.map({ $0.finalGrade }).bind(to: finalGrade).disposed(by: bag)
    }
}
