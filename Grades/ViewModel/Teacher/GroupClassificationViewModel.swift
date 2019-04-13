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

final class GroupClassificationViewModel: TablePickerViewModel {
    typealias Dependencies = HasTeacherRepository

    // MARK: public properties

    var studentsClassification = BehaviorRelay<[TableSection]>(value: [])
    var isloading = PublishSubject<Bool>()
    var error = PublishSubject<Error>()

    // MARK: private properties

    private let dependencies: Dependencies
    private let repository: TeacherRepositoryProtocol
    private let course: Course
    private let user: User
    private let bag = DisposeBag()

    // MARK: initialization

    init(dependencies: AppDependency, course: Course, user: User) {
        self.dependencies = dependencies
        repository = dependencies.teacherRepository
        self.course = course
        self.user = user
        super.init()

        bindOptions(dataSource: studentsClassification)
    }

    // MARK: methods

    func bindOutput() {
        Observable<[TableSection]>.just([
            TableSection(header: "", items: [
                .picker(title: L10n.Teacher.Tab.group, options: ["option 1", "option 3"], valueIndex: 0),
                .picker(title: L10n.Teacher.Students.classification, options: ["option 2"], valueIndex: 0)
            ])
        ])
            .bind(to: studentsClassification)
            .disposed(by: bag)

//        repository.groupOptions.asObservable()
//            .bind(to: groupOptions)
//            .disposed(by: bag)
//
//        repository.classificationOptions.asObservable()
//            .bind(to: classificationOptions)
//            .disposed(by: bag)

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
