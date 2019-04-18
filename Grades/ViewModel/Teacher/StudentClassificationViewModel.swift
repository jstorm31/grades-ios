//
//  StudentClassificationViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift

final class StudentClassificationViewModel {
    typealias Dependencies = HasGradesAPI & HasCourseRepository

    // MARK: public properties

    let students = BehaviorRelay<[User]>(value: [])
    let isloading = BehaviorSubject<Bool>(value: false)
    let error = BehaviorSubject<Error?>(value: nil)
    let totalPoints = PublishSubject<Double?>()
    let finalGrade = PublishSubject<String?>()

    lazy var studentName: Observable<String> = {
        selectedStudent.unwrap().map { $0.name }.share()
    }()

    // MARK: private properties

    private let dependencies: Dependencies
    private let coordinator: SceneCoordinatorType
    private let activityIndicator = ActivityIndicator()
    private let course: Course
    private let bag = DisposeBag()
    private let selectedStudent = BehaviorSubject<User?>(value: nil)

    // MARK: Initialization

    init(dependencies: Dependencies, coordinator: SceneCoordinatorType, course: Course) {
        self.dependencies = dependencies
        self.coordinator = coordinator
        self.course = course

        dependencies.courseRepository.set(course: course)

        activityIndicator
            .distinctUntilChanged()
            .asObservable()
            .bind(to: isloading)
            .disposed(by: bag)
    }

    // MARK: Bindings

    func bindOutput() {
        bindStudents()
    }

    private func bindStudents() {
        let students = dependencies.gradesApi.getTeacherStudents(courseCode: course.code)
            .trackActivity(activityIndicator)
            .catchError { [weak self] error in
                self?.error.onNext(error)
                return Observable.just([])
            }
            .share()

        students.bind(to: self.students).disposed(by: bag)

        // If student is not selected, select first in student's array
        selectedStudent
            .filter { $0 == nil }
            .flatMap { _ in
                students.filter({ !$0.isEmpty }).map({ $0[0] })
            }
            .bind(to: selectedStudent)
            .disposed(by: bag)

        let overview = selectedStudent.unwrap()
            .flatMap { [weak self] student -> Observable<StudentOverview> in
                guard let `self` = self else { return Observable.empty() }
                return self.dependencies.courseRepository.overview(forStudent: student.username).debug()
            }
            .share()

        overview.map({ $0.totalPoints }).bind(to: totalPoints).disposed(by: bag)
        overview.map({ $0.finalGrade }).bind(to: finalGrade).disposed(by: bag)

        dependencies.courseRepository.isFetching.bind(to: isloading).disposed(by: bag)
        dependencies.courseRepository.error.bind(to: error).disposed(by: bag)
    }
}
