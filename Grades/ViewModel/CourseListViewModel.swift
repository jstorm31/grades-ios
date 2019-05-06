//
//  SubjectList.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import Foundation
import RxCocoa
import RxSwift

final class CourseListViewModel: BaseViewModel {
    typealias Dependencies = HasCoursesRepository & HasUserRepository & HasSettingsRepository

    private let dependencies: Dependencies
    private let sceneCoordinator: SceneCoordinatorType
    private let bag = DisposeBag()

    var openSettings: CocoaAction

    // MARK: output

    let courses = BehaviorRelay<CoursesByRoles>(value: CoursesByRoles(student: [], teacher: []))
    let isFetchingCourses = BehaviorSubject<Bool>(value: false)
    let coursesError = BehaviorSubject<Error?>(value: nil)

    // MARK: input

    let refresh = BehaviorSubject<Void>(value: ())

    // MARK: initialization

    init(dependencies: Dependencies, sceneCoordinator: SceneCoordinatorType) {
        self.dependencies = dependencies
        self.sceneCoordinator = sceneCoordinator

        openSettings = CocoaAction {
            let settingsViewModel = SettingsViewModel(coordinator: sceneCoordinator, dependencies: AppDependency.shared)

            sceneCoordinator.transition(to: .settings(settingsViewModel), type: .push)
            return Observable.empty()
        }

        dependencies.coursesRepository.userCourses
            .bind(to: courses)
            .disposed(by: bag)

        dependencies.coursesRepository.isFetching.bind(to: isFetchingCourses).disposed(by: bag)
        dependencies.coursesRepository.error.bind(to: coursesError).disposed(by: bag)
    }

    // MARK: methods

    func bindOutput() {
        Observable.combineLatest(
            dependencies.userRepository.user.asObservable(),
            dependencies.settingsRepository.currentSettings.asObservable(),
            refresh
        ) { user, _, _ -> User? in user }
            .unwrap()
            .subscribe(onNext: { [weak self] user in
                self?.dependencies.coursesRepository.getUserCourses(username: user.username)
            })
            .disposed(by: bag)
    }

    func onItemSelection(_ indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard !courses.value.student.isEmpty else { return }

            let courseDetailVM = CourseDetailStudentViewModel(
                dependencies: AppDependency.shared,
                coordinator: sceneCoordinator,
                course: courses.value.student[indexPath.item]
            )

            sceneCoordinator.transition(to: .courseDetailStudent(courseDetailVM), type: .push)
        } else if indexPath.section == 1 {
            let course = courses.value.teacher[indexPath.item]
            let teacherClassificationVM = TeacherClassificationViewModel(coordinator: sceneCoordinator, course: course)

            sceneCoordinator.transition(to: .teacherClassification(teacherClassificationVM), type: .push)
        }
    }
}
