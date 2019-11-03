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
    typealias Dependencies = HasSceneCoordinator & HasCoursesRepository & HasUserRepository
        & HasSettingsRepository & HasPushNotificationService

    private let dependencies: Dependencies
    private let bag = DisposeBag()

    var openSettings: CocoaAction

    // MARK: Output

    let courses = BehaviorRelay<CoursesByRoles>(value: CoursesByRoles(student: [], teacher: []))
    let filteredCourses = BehaviorRelay<CoursesByRoles>(value: CoursesByRoles(student: [], teacher: []))
    let hiddenCourses = BehaviorRelay<[String]>(value: [])
    let isFetchingCourses = BehaviorSubject<Bool>(value: false)
    let coursesError = BehaviorSubject<Error?>(value: nil)

    // MARK: Input

    let refresh = BehaviorSubject<Void>(value: ())

    // MARK: Initialization

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

    // MARK: Methods

    func bindOutput() {
        processNotification()
        loadFilters()

        hiddenCourses
            .flatMap { [weak self] hiddenCourses -> Observable<CoursesByRoles> in
                // Return filtered user courses
                self?.courses
                    .map { courses in
                        CoursesByRoles(student: courses.student.filter { !hiddenCourses.contains($0.code) },
                                       teacher: courses.teacher.filter { !hiddenCourses.contains($0.code) })
                    } ?? Observable.empty()
            }
            .bind(to: filteredCourses)
            .disposed(by: bag)

        dependencies.coursesRepository.isFetching.bind(to: isFetchingCourses).disposed(by: bag)
        dependencies.coursesRepository.error.bind(to: coursesError).disposed(by: bag)

        // Fetch courses
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
        let courses = filteredCourses.value

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

    func showCourse(for indexPath: IndexPath) {
        if let course = courses.value.course(for: indexPath) {
            hiddenCourses.accept(hiddenCourses.value.filter { $0 != course.code })
        }
    }

    func hideCourse(for indexPath: IndexPath) {
        guard let course = courses.value.course(for: indexPath) else { return }
        var hidden = hiddenCourses.value

        hidden.append(course.code)
        hiddenCourses.accept(hidden)
    }

    func saveFilters() {
        UserDefaults.standard.set(hiddenCourses.value, forKey: Constants.courseFilters)
    }
}

// MARK: Private

private extension CourseListViewModel {
    func transitionToStudentCourse(_ course: StudentCourse) {
        let courseDetailVM = CourseDetailStudentViewModel(dependencies: AppDependency.shared, course: course)
        dependencies.coordinator.transition(to: .courseDetailStudent(courseDetailVM), type: .push)
    }

    func transitionToTeacherCourse(_ course: TeacherCourse) {
        let teacherClassificationVM = TeacherClassificationViewModel(dependencies: AppDependency.shared, course: course)
        dependencies.coordinator.transition(to: .teacherClassification(teacherClassificationVM), type: .push)
    }

    func loadFilters() {
        if let filters = UserDefaults.standard.stringArray(forKey: Constants.courseFilters) {
            hiddenCourses.accept(filters)
        }
    }

    /// Process notificaton if present and transition to course detail
    func processNotification() {
        dependencies.pushNotificationsService.currentNotification.unwrap()
            .debug()
            .flatMap { [weak self] notification in
                self?.dependencies.pushNotificationsService.process(notification: notification) ?? Observable.empty()
            }
            .unwrap()
            .subscribe(onNext: { [weak self] course in
                self?.transitionToStudentCourse(course)
            })
            .disposed(by: bag)
    }
}
