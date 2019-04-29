//
//  TeacherRepository.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift

protocol HasTeacherRepository {
    var teacherRepository: TeacherRepositoryProtocol { get }
}

protocol TeacherRepositoryProtocol {
    var groups: BehaviorRelay<[StudentGroup]> { get }
    var classifications: BehaviorRelay<[Classification]> { get }
    var isLoading: BehaviorSubject<Bool> { get }
    var error: BehaviorSubject<Error?> { get }

    func getGroupOptions(forCourse: String, username: String)
    func getClassificationOptions(forCourse: String)
    func studentClassifications(course: String, groupCode: String, classificationId: String) -> Observable<[StudentClassification]>
}

final class TeacherRepository: TeacherRepositoryProtocol {
    typealias Dependencies = HasGradesAPI

    // MARK: private properties

    private let dependencies: Dependencies
    private let bag = DisposeBag()
    private let activityIndicator = ActivityIndicator()

    // MARK: output

    var groups = BehaviorRelay<[StudentGroup]>(value: [])
    var classifications = BehaviorRelay<[Classification]>(value: [])
    var groupClassifications = BehaviorRelay<[StudentClassification]>(value: [])
    var isLoading = BehaviorSubject<Bool>(value: false)
    var error = BehaviorSubject<Error?>(value: nil)

    // MARK: initializaton

    init(dependencies: AppDependency) {
        self.dependencies = dependencies

        activityIndicator
            .distinctUntilChanged()
            .asObservable()
            .bind(to: isLoading)
            .disposed(by: bag)
    }

    // MARK: methods

    func getGroupOptions(forCourse course: String, username: String) {
        dependencies.gradesApi.getStudentGroups(forCourse: course, username: username)
            .trackActivity(activityIndicator)
            .catchError { [weak self] error in
                self?.error.onNext(error)
                return Observable.just([])
            }
            .bind(to: groups)
            .disposed(by: bag)
    }

    func getClassificationOptions(forCourse course: String) {
        dependencies.gradesApi.getClassifications(forCourse: course)
            .trackActivity(activityIndicator)
            .catchError { [weak self] error in
                self?.error.onNext(error)
                return Observable.just([])
            }
            .bind(to: classifications)
            .disposed(by: bag)
    }

    func studentClassifications(course: String, groupCode: String, classificationId: String) -> Observable<[StudentClassification]> {
        return dependencies.gradesApi.getGroupClassifications(courseCode: course, groupCode: groupCode, classificationId: classificationId)
            .trackActivity(activityIndicator)
            .catchError { [weak self] error in
                self?.error.onNext(error)
                return Observable.just([])
            }
            .map { $0.sorted() }
    }
}
