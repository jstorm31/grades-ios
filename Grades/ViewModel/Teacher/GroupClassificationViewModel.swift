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

final class GroupClassificationViewModel: TablePickerViewModel, DynamicValueFieldArrayViewModelProtocol {
    typealias Dependencies = HasTeacherRepository

    // MARK: public properties

    let studentsClassification = BehaviorRelay<[TableSectionPolymorphic]>(value: [])
    let fieldValues = BehaviorRelay<GroupClassificationViewModel.FieldsDict>(value: [:])
    let isloading = PublishSubject<Bool>()
    let error = PublishSubject<Error>()

    var saveAction = CocoaAction {
        Log.debug("Save not implemented")
        return Observable.empty()
    }

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
        let groupClassifications = repository.groupClassifications.map { $0.sorted() }.share()

        /**
         Build data source for view

         1) Get picker options and create first table section with two picker cells
         2) Get items for chosen group and classification
         */
        Observable.combineLatest(groupSelectedIndex, classificationSelectedIndex) { ($0, $1) }
            .flatMap { [weak self] indexes -> Observable<TableSectionPolymorphic> in
                guard let `self` = self else {
                    return Observable.just(TableSectionPolymorphic(header: "", items: []))
                }

                return Observable.zip(
                    self.repository.groups,
                    self.repository.classifications
                ) { (groups, classifications) -> TableSectionPolymorphic in
                    TableSectionPolymorphic(header: "", items: [
                        CellItemType.picker(
                            title: L10n.Teacher.Students.group,
                            options: groups.map { $0.id },
                            valueIndex: indexes.0
                        ),
                        CellItemType.picker(
                            title: L10n.Teacher.Students.classification,
                            options: classifications.map { $0.getLocalizedText() },
                            valueIndex: indexes.1
                        )
                    ])
                }.asObservable()
            }
            .flatMap { [weak self] headerSection in
                self?.buildDatasourceItems(groupClassifications).map { studentClassifications in
                    [headerSection, TableSectionPolymorphic(header: L10n.Teacher.Group.students, items: studentClassifications)]
                }.asObservable() ?? Observable.just([])
            }
            .bind(to: studentsClassification)
            .disposed(by: bag)

        groupClassifications
            .map { Dictionary(uniqueKeysWithValues: $0.map { ($0.username, $0.value) }) }
            .bind(to: fieldValues)
            .disposed(by: bag)

        repository.isLoading.bind(to: isloading).disposed(by: bag)
        repository.error.unwrap().bind(to: error).disposed(by: bag)
    }

    /// Initialize and bind CellViewModel for each item
    func buildDatasourceItems(_ source: Observable<[StudentClassification]>) -> Observable<[CellItemType]> {
        return source
            .map { [weak self] (classifications: [StudentClassification]) -> [CellItemType] in
                guard let `self` = self else { return [] }

                return classifications.map { (item: StudentClassification) -> CellItemType in
                    let cellViewModel = DynamicValueCellViewModel(
                        key: item.username,
                        title: "\(item.lastName ?? "") \(item.firstName ?? "")"
                    )

                    self.bind(cellViewModel: cellViewModel)
                    return .dynamicValue(viewModel: cellViewModel)
                }
            }
    }

    /// Submit current value for current index path
    func submitSelectedValue() {
        guard let index = self.selectedCellIndex.value else { return }

        if index.section == 0, index.item == 0 {
            groupSelectedIndex.accept(selectedOptionIndex.value)
        } else if index.section == 0, index.item == 1 {
            classificationSelectedIndex.accept(selectedOptionIndex.value)
        }

        getData()
    }

    /// Get students for selected group and classifiaction
    func getData() {
        repository.getClassificationOptions(forCourse: course.code)
        repository.getGroupOptions(forCourse: course.code, username: user.username)

        guard !repository.groups.value.isEmpty, !repository.classifications.value.isEmpty else { return }

        let groupCode = repository.groups.value[groupSelectedIndex.value]
        let classificationId = repository.classifications.value[classificationSelectedIndex.value]
        // TODO: pořešit value type pro celou tabulku vs. pro jednotlivé buňky
        //        let valueType = repository.classifications.value[classificationSelectedIndex.value].valueType

        repository.studentsFor(course: course.code, groupCode: groupCode.id, classificationId: classificationId.identifier)
    }
}
