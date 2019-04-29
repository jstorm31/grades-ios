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

    let dataSource = BehaviorRelay<[TableSection]>(value: [])
    let isloading = PublishSubject<Bool>()
    let error = PublishSubject<Error>()

    lazy var selectedCellOptionIndex: Observable<Int> = {
        selectedCellIndex
            .unwrap()
            .filter { $0.section == 0 }
            .map { $0.item }
            .flatMap { [weak self] cellIndex -> Observable<Int> in
                guard let `self` = self else { return Observable.just(0) }

                return Observable.combineLatest(self.groupSelectedIndex,
                                                self.classificationSelectedIndex) { groupIndex, classificationIndex in
                    if cellIndex == 0 {
                        return groupIndex
                    } else if cellIndex == 1 {
                        return classificationIndex
                    }
                    return 0
                }
            }
    }()

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

    private let groupsCellViewModel = PickerCellViewModel(title: L10n.Teacher.Students.group)
    private let classificationsCellViewModel = PickerCellViewModel(title: L10n.Teacher.Students.classification)

    internal let fieldValues = BehaviorRelay<[String: DynamicValue?]>(value: [:])

    // MARK: initialization

    init(dependencies: AppDependency, course: Course, user: User) {
        self.dependencies = dependencies
        repository = dependencies.teacherRepository
        self.course = course
        self.user = user
        super.init()
    }

    // MARK: methods

    func bindOutput() {
        bindOptions()

        let groupClassifications = repository.groupClassifications.map { $0.sorted() }.share()

        /**
         Build data source for view

         1) Get picker options and create first table section with two picker cells
         2) Get items for chosen group and classification
         */
        Observable.combineLatest(groupSelectedIndex, classificationSelectedIndex) { _, _ in }
            .map { [weak self] _ in
                guard let `self` = self else { return TableSection(header: "", items: []) }

                return TableSection(header: "", items: [
                    PickerCellConfigurator(item: self.groupsCellViewModel),
                    PickerCellConfigurator(item: self.classificationsCellViewModel)
                ])
            }
            .flatMap { [weak self] headerSection in
                self?.buildDatasourceItems(groupClassifications).map { studentClassifications in
                    [headerSection, TableSection(header: L10n.Teacher.Group.students, items: studentClassifications)]
                }.asObservable() ?? Observable.just([])
            }
            .bind(to: dataSource)
            .disposed(by: bag)

        groupClassifications
            .map { Dictionary(uniqueKeysWithValues: $0.map { ($0.username, $0.value) }) }
            .bind(to: fieldValues)
            .disposed(by: bag)

        repository.isLoading.bind(to: isloading).disposed(by: bag)
        repository.error.unwrap().bind(to: error).disposed(by: bag)
    }

    /// Initialize and bind CellViewModel for each item
    func buildDatasourceItems(_ source: Observable<[StudentClassification]>) -> Observable<[DynamicValueCellConfigurator]> {
        return source
            .map { [weak self] (classifications: [StudentClassification]) -> [DynamicValueCellConfigurator] in
                guard let `self` = self else { return [] }

                return classifications.map { (item: StudentClassification) -> DynamicValueCellConfigurator in
                    let valueType = self.repository.classifications.value[self.classificationSelectedIndex.value].valueType

                    let cellViewModel = DynamicValueCellViewModel(
                        valueType: valueType,
                        key: item.username,
                        title: "\(item.lastName ?? "") \(item.firstName ?? "")"
                    )

//                    self.bind(cellViewModel: cellViewModel)
                    return DynamicValueCellConfigurator(item: cellViewModel)
                }
            }
    }

    /// Bind selected options
    func bindOptions() {
        groupSelectedIndex
            .flatMap { [weak self] index -> Observable<String> in
                self?.repository.groups.map { options in
                    if options.count - 1 > index {
                        return options[index].id
                    }
                    return ""
                } ?? Observable.just("")
            }
            .bind(to: groupsCellViewModel.selectedOption)
            .disposed(by: bag)

        classificationSelectedIndex
            .flatMap { [weak self] index -> Observable<String> in
                self?.repository.classifications.map { options in
                    if options.count - 1 > index {
                        return options[index].getLocalizedText()
                    }
                    return ""
                } ?? Observable.just("")
            }
            .bind(to: classificationsCellViewModel.selectedOption)
            .disposed(by: bag)

        selectedCellIndex
            .unwrap()
            .filter { $0.section == 0 }
            .map { $0.item }
            .flatMap { [weak self] index -> Observable<[String]> in
                guard let `self` = self else { return Observable.just([]) }

                if index == 0 {
                    return self.repository.groups.map { $0.map { $0.id } }
                } else if index == 1 {
                    return self.repository.classifications.map { $0.map { $0.getLocalizedText() } }
                }
                return Observable.just([])
            }
            .bind(to: options)
            .disposed(by: bag)
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

        repository.studentsFor(course: course.code, groupCode: groupCode.id, classificationId: classificationId.identifier)
    }
}
