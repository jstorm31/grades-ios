//
//  StudentClassificationViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxCocoa
import RxSwift

final class StudentClassificationViewModel: BaseViewModel, DynamicValueFieldArrayViewModelProtocol {
    typealias Dependencies = HasGradesAPI & HasCourseRepository

    // MARK: Public properties

    let dataSource = BehaviorRelay<[TableSection]>(value: [])
    let students = BehaviorRelay<[User]>(value: [])
    let isloading = BehaviorSubject<Bool>(value: false)
    let error = BehaviorSubject<Error?>(value: nil)
    let totalPoints = PublishSubject<Double?>()
    let finalGrade = PublishSubject<String?>()

    lazy var studentName: Observable<String> = {
        selectedStudent.unwrap().map { $0.name }.share()
    }()

    // MARK: Actions

    lazy var changeStudentAction = CocoaAction { [weak self] in
        guard let `self` = self else { return Observable.empty() }

        let studentSearchViewModel = StudentSearchViewModel(
            coordinator: self.coordinator,
            students: self.students,
            selectedStudent: self.selectedStudent
        )
        return self.coordinator.transition(to: .studentSearch(studentSearchViewModel), type: .push)
            .asObservable().map { _ in }
    }

    lazy var saveAction = CocoaAction { [weak self] in
        Observable.just(self?.fieldValues.value)
            .unwrap()
            .map { $0.filter { $0.value != nil } }
            .map { [weak self] values -> [StudentClassification] in
                guard let `self` = self else { return [] }

                let username = self.selectedStudent.value?.username ?? ""
                return values.map { StudentClassification(identifier: $0.key, username: username, value: $0.value) }
            }
            .flatMap { [weak self] classifications -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                return self.dependencies.gradesApi.putStudentsClassifications(courseCode: self.course.code, data: classifications)
            }
            .do(onCompleted: { [weak self] in
                self?.bindOutput()
            })
    }

    // MARK: private properties

    internal let fieldValues = BehaviorRelay<[String: DynamicValue?]>(value: [:])
    private let selectedStudent = BehaviorRelay<User?>(value: nil)
    private let course: Course

    private let dependencies: Dependencies
    private let coordinator: SceneCoordinatorType
    private let activityIndicator = ActivityIndicator()
    private let bag = DisposeBag()

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
        bindDataSource()

        dependencies.courseRepository.isFetching.bind(to: isloading).disposed(by: bag)
        dependencies.courseRepository.error.bind(to: error).disposed(by: bag)
    }

    private func bindStudents() {
        let students = dependencies.gradesApi.getTeacherStudents(courseCode: course.code)
            .trackActivity(activityIndicator)
            .catchError { [weak self] error in
                self?.error.onNext(error)
                return Observable.just([])
            }
            .share(replay: 1, scope: .whileConnected)

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
                self?.dependencies.courseRepository.overview(forStudent: student.username) ?? Observable.empty()
            }
            .trackActivity(activityIndicator)
            .share()

        overview.map({ $0.totalPoints }).bind(to: totalPoints).disposed(by: bag)
        overview.map({ $0.finalGrade }).bind(to: finalGrade).disposed(by: bag)
    }

    private func bindDataSource() {
        // Get classifications
        let classifications = selectedStudent.unwrap()
            .flatMap { [weak self] student -> Observable<[Classification]> in
                self?.dependencies.courseRepository.classifications(forStudent: student.username) ?? Observable.just([])
            }
            .share()

        // Bind to data source
        classifications
            .map { [weak self] classifications in
                classifications.map { classification in
                    let cellViewModel = DynamicValueCellViewModel(
                        valueType: classification.valueType,
                        key: classification.identifier,
                        title: classification.getLocalizedText()
                    )
                    self?.bind(cellViewModel: cellViewModel)

                    return DynamicValueCellConfigurator(item: cellViewModel)
                }
            }
            .map { [TableSection(header: L10n.Teacher.Students.grading, items: $0)] }
            .bind(to: dataSource)
            .disposed(by: bag)

        // Bind to fields array
        classifications
            .map { Dictionary(uniqueKeysWithValues: $0.map { ($0.identifier, $0.value) }) }
            .bind(to: fieldValues)
            .disposed(by: bag)
    }
}
