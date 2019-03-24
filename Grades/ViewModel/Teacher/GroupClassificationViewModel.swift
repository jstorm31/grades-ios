//
//  CourseGroupClassificationViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxCocoa
import RxSwift

protocol GroupClassificationViewModelProtocol {
    var studentsClassification: BehaviorSubject<[StudentsClassificationSection]> { get }
    var groupOptions: PublishSubject<[StudentGroup]> { get }
    var classificationOptions: PublishSubject<[ClassificationOption]> { get }
    var isloading: PublishSubject<Bool> { get }
    var error: PublishSubject<Error> { get }

    func bindOutput()
}

final class GroupClassificationViewModel: BaseViewModel, GroupClassificationViewModelProtocol {
    typealias Dependencies = HasTeacherRepository

    private let dependencies: Dependencies
    private let repository: TeacherRepositoryProtocol
    private let course: Course
    private let user: User
    private let bag = DisposeBag()

    var studentsClassification = BehaviorSubject<[StudentsClassificationSection]>(value: [])

    var groupOptions = PublishSubject<[StudentGroup]>()
    var classificationOptions = PublishSubject<[ClassificationOption]>()
    var isloading = PublishSubject<Bool>()
    var error = PublishSubject<Error>()

    init(dependencies: AppDependency, course: Course, user: User) {
        self.dependencies = dependencies
        repository = dependencies.teacherRepository
        self.course = course
        self.user = user
    }

    func bindOutput() {
        Observable.just([
            StudentsClassificationSection(header: "", items: [
                StudentsClassificationItem.picker(title: L10n.Teacher.Tab.group, value: "Placeholder group"),
                StudentsClassificationItem.picker(title: L10n.Teacher.Students.classification, value: "Placeholder classification")
            ])
        ])
            .bind(to: studentsClassification)
            .disposed(by: bag)

        repository.groupOptions.asObservable()
            .bind(to: groupOptions)
            .disposed(by: bag)

        repository.classificationOptions.asObservable()
            .bind(to: classificationOptions)
            .disposed(by: bag)

        repository.isLoading.asObserver()
            .bind(to: isloading)
            .disposed(by: bag)

        repository.error.asObservable().unwrap()
            .bind(to: error)
            .disposed(by: bag)

        repository.getClassificationOptions(forCourse: course.code)
        repository.getGroupOptions(forCourse: course.code, username: user.username)
    }
}
