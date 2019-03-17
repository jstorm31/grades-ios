//
//  SubjectList.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class CourseListViewModel: BaseViewModel {
    private let sceneCoordinator: SceneCoordinatorType
    private let gradesApi: GradesAPIProtocol
    private let kosApi: KosApiProtocol
    private let user: UserInfo
    private let settings = SettingsRepository()
    private let activityIndicator = ActivityIndicator()
    private let bag = DisposeBag()

    init(sceneCoordinator: SceneCoordinatorType, gradesApi: GradesAPIProtocol, kosApi: KosApiProtocol, user: UserInfo) {
        self.gradesApi = gradesApi
        self.kosApi = kosApi
        self.user = user
        self.sceneCoordinator = sceneCoordinator

        activityIndicator
            .distinctUntilChanged()
            .asObservable()
            .bind(to: isFetchingCourses)
            .disposed(by: bag)
    }

    // MARK: output

    let courses = BehaviorRelay<[CourseGroup]>(value: [])
    let isFetchingCourses = BehaviorRelay<Bool>(value: false)
    let coursesError = BehaviorRelay<Error?>(value: nil)

    // MARK: methods

    func bindOutput() {
        getCourses()
            .trackActivity(activityIndicator)
            .catchError { [weak self] error in
                if let `self` = self {
                    Observable.just(error).bind(to: self.coursesError).disposed(by: self.bag)
                }

                return Observable.just([])
            }
            .bind(to: courses)
            .disposed(by: bag)
    }

    /// Fetches courses from api and transforms them to right format
    private func getCourses() -> Observable<[CourseGroup]> {
        let courses = gradesApi.getCourses(username: user.username)

            // Fetch course name from kosAPI for each course
            .flatMap { (courses: [Course]) -> Observable<[Course]> in
                Observable.from(courses).flatMap { [weak self] (course: Course) -> Observable<Course> in
                    guard let `self` = self else { return .empty() }

                    return self.kosApi.getCourseName(code: course.code)
                        .map { (name: String) -> Course in
                            var courseWithName = Course(fromCourse: course)
                            courseWithName.name = name
                            return courseWithName
                        }
                }.toArray()
            }

        return Observable.zip(courses, gradesApi.getRoles()) { (courses: [Course], roles: UserRoles) -> [CourseGroup] in
            let sectionTitles = [L10n.Courses.studying, L10n.Courses.teaching]

            // Map courses to roles
            return [roles.studentCourses, roles.teacherCourses]
                .map { courseGroup in
                    courseGroup.compactMap { code in
                        courses.first(where: {
                            $0.code == code
                        })
                    }
                }
                .filter { !$0.isEmpty }
                .enumerated()

                // Map to [CourseGroup]
                .map { offset, element in
                    CourseGroup(header: sectionTitles[offset], items: element)
                }
        }
    }

    func onItemSelection(section: Int, item: Int) {
        let course = courses.value[section].items[item]
        let repository = CourseStudentRepository(username: user.username, code: course.code, name: course.name, gradesApi: gradesApi)
        let courseDetailVM = CourseDetailStudentViewModel(coordinator: sceneCoordinator, repository: repository)

        sceneCoordinator.transition(to: .courseDetailStudent(courseDetailVM), type: .push)
    }
}
