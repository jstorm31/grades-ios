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
    typealias Dependencies = HasCoursesRepository

    private let dependencies: Dependencies
    private let sceneCoordinator: SceneCoordinatorType
    private let user: User
    private let bag = DisposeBag()

    var openSettings: CocoaAction

    // MARK: output

    let courses = BehaviorSubject<[CourseGroup]>(value: [])
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
            .map { coursesByRoles in
                [
                    CourseGroup(
                        header: L10n.Courses.studying,
                        items: coursesByRoles.student.map { StudentCourseCellConfigurator(item: $0) }
                    ),
                    CourseGroup(
                        header: L10n.Courses.teaching,
                        items: coursesByRoles.teacher.map { TeacherCourseCellConfigurator(item: $0) }
                    )
                ]
            }
            .bind(to: courses)
            .disposed(by: bag)

        dependencies.coursesRepository.isFetching.bind(to: isFetchingCourses).disposed(by: bag)
        dependencies.coursesRepository.error.bind(to: coursesError).disposed(by: bag)
    }

    // MARK: methods

    func bindOutput() {
        dependencies.coursesRepository.getUserCourses(username: user.username)
    }

    func onItemSelection(section _: Int, item _: Int) {
//        let course = courses.value[section].items[item]
//        let courseDetail = Course(code: course.item.code, name: course.name)
//        let repository = CourseStudentRepository(dependencies: AppDependency.shared, username: user.username, course: courseDetail)
//        let courseDetailVM = CourseDetailStudentViewModel(coordinator: sceneCoordinator, repository: repository)
//
//        sceneCoordinator.transition(to: .courseDetailStudent(courseDetailVM), type: .push)
    }
}
