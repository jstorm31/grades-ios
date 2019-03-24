//
//  TeacherRepository.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift

typealias ClassificationOption = (id: Int, title: String)

protocol HasTeacherRepository {
    var teacherRepository: TeacherRepositoryProtocol { get }
}

protocol TeacherRepositoryProtocol {
    var groupOptions: BehaviorRelay<[StudentGroup]> { get }
    var classificationOptions: BehaviorRelay<[ClassificationOption]> { get }
    var isLoading: BehaviorSubject<Bool> { get }
    var error: BehaviorSubject<Error?> { get }

    func getGroupOptions(forCourse: String, username: String)
    func getClassificationOptions(forCourse: String)
    func studentsFor(groupId: Int, classificationId: Int)
}

final class TeacherRepository: TeacherRepositoryProtocol {
    typealias Dependencies = HasGradesAPI

    // MARK: private properties

    private let dependencies: Dependencies
    private let bag = DisposeBag()
    private let activityIndicator = ActivityIndicator()

    // MARK: output

    var groupOptions = BehaviorRelay<[StudentGroup]>(value: [])
    var classificationOptions = BehaviorRelay<[ClassificationOption]>(value: [])
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
            .bind(to: groupOptions)
            .disposed(by: bag)
    }

    func getClassificationOptions(forCourse course: String) {
        dependencies.gradesApi.getClassifications(forCourse: course)
            .map { (classifications: [Classification]) -> [ClassificationOption] in
                classifications.map { (id: $0.id, title: $0.getLocalizedText()) }
            }
            .trackActivity(activityIndicator)
            .catchError { [weak self] error in
                self?.error.onNext(error)
                return Observable.just([])
            }
            .bind(to: classificationOptions)
            .disposed(by: bag)
    }

    func studentsFor(groupId: Int, classificationId: Int) {
        Log.info("TODO: fetch students for group \(groupId) and classification \(classificationId)")
    }
}
