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

    let studentsClassification = BehaviorRelay<[TableSection]>(value: [])
    let isloading = PublishSubject<Bool>()
    let error = PublishSubject<Error>()

    // MARK: private properties

    private let dependencies: Dependencies
    private let repository: TeacherRepositoryProtocol
    private let course: Course
    private let user: User
    private let bag = DisposeBag()

    private let groupSelectedIndex = BehaviorSubject<Int>(value: 0)
    private let classificationSelectedIndex = BehaviorSubject<Int>(value: 0)

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
        Observable<[TableSection]>.combineLatest(
            groupSelectedIndex,
            classificationSelectedIndex,
            repository.groupOptions,
            repository.classificationOptions
        ) { groupIndex, classificationIndex, groupOptions, classificationOptions in
            [
                TableSection(header: "", items: [
                    .picker(
                        title: L10n.Teacher.Tab.group,
                        options: groupOptions.map { $0.id },
                        valueIndex: groupIndex
                    ),
                    .picker(
                        title: L10n.Teacher.Students.classification,
                        options: classificationOptions.map { String($0.id) },
                        valueIndex: classificationIndex
                    )
                ])
            ]
        }
        .bind(to: studentsClassification)
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

    /// Submit current value for current index path
    func submitSelectedValue() {
        guard let index = self.selectedCellIndex.value else { return }

        if index.section == 0, index.item == 0 {
            groupSelectedIndex.onNext(selectedOptionIndex.value)
        } else if index.section == 0, index.item == 1 {
            classificationSelectedIndex.onNext(selectedOptionIndex.value)
        }
    }
}
