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

    private let groupSelectedIndex = BehaviorRelay<Int>(value: 0)
    private let classificationSelectedIndex = BehaviorRelay<Int>(value: 0)

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
        let groupClassifications = repository.groupClassifications
            .map { $0.sorted() }
            .map { $0.map { CellItemType.textField(
                title: "\($0.firstName ?? "") \($0.lastName ?? "")",
                subtitle: $0.username,
                value: $0.value ?? .number(0)
            ) } }

        // swiftlint:disable line_length
        Observable<[TableSection]>.combineLatest(
            groupSelectedIndex,
            classificationSelectedIndex,
            repository.groups,
            repository.classifications,
            groupClassifications
        ) { (groupIndex, classificationIndex, groups: [StudentGroup], classifications: [Classification], groupClassifications) -> [TableSection] in
            [
                TableSection(header: "", items: [
                    CellItemType.picker(
                        title: L10n.Teacher.Tab.group,
                        options: groups.map { (key: $0.id, value: $0.id) },
                        valueIndex: groupIndex
                    ),
                    CellItemType.picker(
                        title: L10n.Teacher.Students.classification,
                        options: classifications.map { (key: $0.identifier, value: $0.getLocalizedText()) },
                        valueIndex: classificationIndex
                    )
                ]),
                TableSection(header: L10n.Teacher.Group.students, items: groupClassifications)
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
            groupSelectedIndex.accept(selectedOptionIndex.value)
        } else if index.section == 0, index.item == 1 {
            classificationSelectedIndex.accept(selectedOptionIndex.value)
        }

        // Get students for selected group and classifiaction
        let groupCode = repository.groups.value[groupSelectedIndex.value]
        let classificationId = repository.classifications.value[classificationSelectedIndex.value]
        repository.studentsFor(course: course.code, groupCode: groupCode.id, classificationId: String(classificationId.id))
    }
}
