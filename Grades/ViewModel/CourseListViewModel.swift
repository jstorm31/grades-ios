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

typealias StudentCourseCellConfigurator = TableCellConfigurator<StudentCourseCell, StudentCourse>
typealias TeacherCourseCellConfigurator = TableCellConfigurator<TeacherCourseCell, TeacherCourse>

class CourseListViewModel: BaseViewModel {
    typealias Dependencies = HasCoursesRepository & HasCourseStudentRepositoryFactory

    private let dependencies: Dependencies
    private let sceneCoordinator: SceneCoordinatorType
    private let user: User
    private let bag = DisposeBag()

    var openSettings: CocoaAction

    // MARK: output

    let courses = BehaviorRelay<CoursesByRoles>(value: CoursesByRoles(student: [], teacher: []))
    let isFetchingCourses = BehaviorSubject<Bool>(value: false)
    let coursesError = BehaviorSubject<Error?>(value: nil)

    // MARK: initialization

    init(dependencies: Dependencies, sceneCoordinator: SceneCoordinatorType, user: User) {
        self.dependencies = dependencies
        self.user = user
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
        dependencies.coursesRepository.getUserCourses(username: user.username)
    }

    func onItemSelection(_ indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard !courses.value.student.isEmpty else { return }

            let course = courses.value.student[indexPath.item]
            let repository = dependencies.courseStudentRepositoryFactory(user.username, course)
            let courseDetailVM = CourseDetailStudentViewModel(coordinator: sceneCoordinator, repository: repository)

            sceneCoordinator.transition(to: .courseDetailStudent(courseDetailVM), type: .push)
            Log.debug("Transitioned")
        } else if indexPath.section == 1 {
            Log.info("Selected teacher cell at index: \(indexPath.item)")
        }
    }
}
