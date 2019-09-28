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
    typealias Dependencies = HasSceneCoordinator & HasCoursesRepository & HasUserRepository & HasSettingsRepository

    private let dependencies: Dependencies
    private let bag = DisposeBag()

    var openSettings: CocoaAction

    // MARK: output

    let courses = BehaviorRelay<CoursesByRoles>(value: CoursesByRoles(student: [], teacher: []))
    let dataSource = BehaviorSubject<CoursesByRoles>(value: CoursesByRoles(student: [], teacher: []))
    let isFetchingCourses = BehaviorSubject<Bool>(value: false)
    let coursesError = BehaviorSubject<Error?>(value: nil)

    // MARK: input

    let refresh = BehaviorSubject<Void>(value: ())
    let hiddenCourses = BehaviorSubject<[IndexPath]>(value: [IndexPath(item: 1, section: 0)])

    // MARK: initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        openSettings = CocoaAction {
            let settingsViewModel = SettingsViewModel(dependencies: AppDependency.shared)
            return dependencies.coordinator.transition(to: .settings(settingsViewModel), type: .push)
                .asObservable().map { _ in }
        }

        dependencies.coursesRepository.userCourses
            .bind(to: courses)
            .disposed(by: bag)
    }

    // MARK: methods

    func bindOutput() {
        hiddenCourses
            .flatMap { [weak self] hiddenCourses -> Observable<CoursesByRoles> in
                // Return filtered user courses
                self?.courses
                    .map { courses in
                        var filteredCourses = courses

                        for indexPath in hiddenCourses {
                            if indexPath.section == 0, !filteredCourses.student.isEmpty {
                                filteredCourses.student.remove(at: indexPath.item)
                            } else if indexPath.section == 1, !filteredCourses.teacher.isEmpty {
                                filteredCourses.teacher.remove(at: indexPath.item)
                            }
                        }
                        return filteredCourses
                    } ?? Observable.empty()
            }
            .bind(to: dataSource)
            .disposed(by: bag)

        dependencies.coursesRepository.isFetching.bind(to: isFetchingCourses).disposed(by: bag)
        dependencies.coursesRepository.error.bind(to: coursesError).disposed(by: bag)

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
        let courses = self.courses.value

        if courses.student.isEmpty, !courses.teacher.isEmpty {
            // Only student courses
            transitionToTeacherCourse(courses.teacher[indexPath.item])
        } else if !courses.student.isEmpty, courses.teacher.isEmpty {
            // Only teacher courses
            transitionToStudentCourse(courses.student[indexPath.item])
        } else if !courses.student.isEmpty, !courses.teacher.isEmpty {
            // Both student and teacher courses
            if indexPath.section == 0 {
                let course = courses.student[indexPath.item]
                transitionToStudentCourse(course)
            } else if indexPath.section == 1 {
                let course = courses.teacher[indexPath.item]
                transitionToTeacherCourse(course)
            }
        }
    }

    private func transitionToStudentCourse(_ course: StudentCourse) {
        let courseDetailVM = CourseDetailStudentViewModel(dependencies: AppDependency.shared, course: course)
        dependencies.coordinator.transition(to: .courseDetailStudent(courseDetailVM), type: .push)
    }

    private func transitionToTeacherCourse(_ course: TeacherCourse) {
        let teacherClassificationVM = TeacherClassificationViewModel(dependencies: AppDependency.shared, course: course)
        dependencies.coordinator.transition(to: .teacherClassification(teacherClassificationVM), type: .push)
    }
}
