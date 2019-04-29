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
    typealias Dependencies = HasTeacherRepository & HasGradesAPI

    // MARK: public properties

    let dataSource = BehaviorRelay<[TableSection]>(value: [])
    let isloading = PublishSubject<Bool>()
    let error = PublishSubject<Error>()
    let refreshData = BehaviorSubject<Void>(value: ())

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

    lazy var saveAction = CocoaAction { [weak self] in
        Observable.just(self?.dynamicCellViewModels)
            .unwrap()
            .map { $0.filter { $0.value.value != nil } }
            .map { [weak self] values -> [StudentClassification] in
                guard let `self` = self else { return [] }

                let identifier = self.repository.classifications.value[self.classificationSelectedIndex.value].identifier
                return values.map { StudentClassification(identifier: identifier, username: $0.key, value: $0.value.value) }
            }
            .flatMap { [weak self] classifications -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                return self.dependencies.gradesApi.putStudentsClassifications(courseCode: self.course.code, data: classifications)
            }
            .do(onCompleted: { [weak self] in
                self?.refreshData.onNext(())
            })
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

    private var dynamicCellViewModels = [DynamicValueCellViewModel]()

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

        /**
         Build data source for view

         1) Get picker options and create first table section with two picker cells
         2) Get items for chosen group and classification
         */
        Observable.zip(repository.groups, repository.classifications) { $1 }
            .filter { !$0.isEmpty }
            .flatMap { [weak self] classifications -> Observable<(DynamicValueType, Int, Int)> in
                guard let `self` = self else { return Observable.empty() }

                return Observable.combineLatest(self.refreshData, self.groupSelectedIndex, self.classificationSelectedIndex) { ($1, $2) }
                    .map { indexes in
                        let (groupIndex, classificationIndex) = indexes

                        return (classifications[classificationIndex].valueType, groupIndex, classificationIndex)
                    }
            }
            .flatMap { [weak self] arg -> Observable<TableSection> in
                let (valueType, groupIndex, classificationIndex) = arg

                return self?.studentClassifications(valueType, groupIndex, classificationIndex)
                    .map { studentClassifications in
                        TableSection(header: L10n.Teacher.Group.students, items: studentClassifications)
                    } ?? Observable.empty()
            }
            .map { [weak self] itemsSection in
                guard let `self` = self else { return [] }

                return [
                    TableSection(header: "", items: [
                        PickerCellConfigurator(item: self.groupsCellViewModel),
                        PickerCellConfigurator(item: self.classificationsCellViewModel)
                    ]),
                    itemsSection
                ]
            }
            .bind(to: dataSource)
            .disposed(by: bag)

        repository.getClassificationOptions(forCourse: course.code)
        repository.getGroupOptions(forCourse: course.code, username: user.username)
        repository.isLoading.bind(to: isloading).disposed(by: bag)
        repository.error.unwrap().bind(to: error).disposed(by: bag)
    }

    /// Initialize and bind CellViewModel for each item
    private func studentClassifications(_ valueType: DynamicValueType, _ groupIndex: Int, _ classificationIndex: Int) -> Observable<[DynamicValueCellConfigurator]> {
        let groupCode = repository.groups.value[groupIndex]
        let classificationId = repository.classifications.value[classificationIndex]

        return repository.studentClassifications(course: course.code, groupCode: groupCode.id,
                                                 classificationId: classificationId.identifier)
            .do(onNext: { [weak self] _ in
                self?.dynamicCellViewModels = [] // Reset view models array to clean memory
            })
            .map { [weak self] (classifications: [StudentClassification]) -> [DynamicValueCellConfigurator] in
                guard let `self` = self else { return [] }

                return classifications.map { (item: StudentClassification) -> DynamicValueCellConfigurator in
                    let cellViewModel = DynamicValueCellViewModel(
                        valueType: valueType,
                        key: item.username,
                        title: "\(item.lastName ?? "") \(item.firstName ?? "")"
                    )
                    cellViewModel.value.accept(item.value)
                    self.dynamicCellViewModels.append(cellViewModel)

                    return DynamicValueCellConfigurator(item: cellViewModel)
                }
            }
    }

    /// Bind selected options
    private func bindOptions() {
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
    }
}
