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

final class GroupClassificationViewModel: TablePickerViewModel, SortableDataViewModel {
    typealias Dependencies = HasTeacherRepository & HasGradesAPI & HasSettingsRepository

    // MARK: public properties

    let dataSource = BehaviorRelay<[DynamicValueCellViewModel]>(value: [])
    let isloading = BehaviorSubject<Bool>(value: false)
    let error = PublishSubject<Error>()
    let sorters = BehaviorSubject<[StudentClassificationSorter]>(value: [StudentClassificationNameSorter(),
                                                                         StudentClassificationValueSorter()])

    let groupsCellViewModel = PickerCellViewModel(title: L10n.Teacher.Students.group)
    let classificationsCellViewModel = PickerCellViewModel(title: L10n.Teacher.Students.classification)

    // MARK: input

    let refreshData = BehaviorSubject<Void>(value: ())
    let activeSorterIndex = BehaviorSubject<Int>(value: 0)
    let isAscending = BehaviorSubject<Bool>(value: true)

    lazy var selectedCellOptionIndex: Observable<Int> = {
        selectedCellIndex
            .unwrap()
            .filter { $0.section == 0 }
            .map { $0.item }
            .flatMap { [weak self] cellIndex -> Observable<Int> in
                guard let self = self else { return Observable.just(0) }

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
                guard let self = self else { return [] }

                let identifier = self.teacherRepository.classifications.value[self.classificationSelectedIndex.value].identifier
                return values.map { StudentClassification(identifier: identifier, username: $0.key, value: $0.value.value) }
            }
            .flatMap { [weak self] classifications -> Observable<Void> in
                guard let self = self else { return Observable.empty() }
                let settings = self.dependencies.settingsRepository.currentSettings.value

                return self.dependencies.gradesApi.putStudentsClassifications(courseCode: self.course.code,
                                                                              data: classifications,
                                                                              notify: settings.sendingNotificationsEnabled)
            }
            .do(onCompleted: { [weak self] in
                self?.refreshData.onNext(())
            })
    }

    // MARK: private properties

    private let dependencies: Dependencies
    private let teacherRepository: TeacherRepositoryProtocol
    private let course: Course
    private let bag = DisposeBag()

    private let groupSelectedIndex = BehaviorRelay<Int>(value: 0)
    private let classificationSelectedIndex = BehaviorRelay<Int>(value: 0)

    private var dynamicCellViewModels = [DynamicValueCellViewModel]()

    // MARK: initialization

    init(dependencies: Dependencies, course: Course) {
        self.dependencies = dependencies
        teacherRepository = dependencies.teacherRepository
        self.course = course
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
        Observable.zip(teacherRepository.groups, teacherRepository.classifications) { $1 }
            .flatMap { [weak self] classifications -> Observable<(Classification, Int, Int)> in
                guard let self = self else { return Observable.empty() }

                return Observable.combineLatest(self.refreshData, self.groupSelectedIndex, self.classificationSelectedIndex) { ($1, $2) }
                    .filter { classifications.count > $1 }
                    .map { indexes in
                        let (groupIndex, classificationIndex) = indexes

                        return (classifications[classificationIndex], groupIndex, classificationIndex)
                    }
            }
            .flatMap { [weak self] arg -> Observable<[DynamicValueCellViewModel]> in
                guard let self = self else { return Observable.empty() }
                let (classification, groupIndex, classificationIndex) = arg

                return self.studentClassifications(classification, groupIndex, classificationIndex)
            }
            .bind(to: dataSource)
            .disposed(by: bag)

        teacherRepository.getGroupOptions(forCourse: course.code)
        teacherRepository.getClassificationOptions(forCourse: course.code)
        teacherRepository.isLoading.bind(to: isloading).disposed(by: bag)
        teacherRepository.error.unwrap().bind(to: error).disposed(by: bag)
    }

    /// Initialize and bind CellViewModel for each item
    private func studentClassifications(_ classification: Classification,
                                        _ groupIndex: Int,
                                        _ classificationIndex: Int) -> Observable<[DynamicValueCellViewModel]>
    {
        guard groupIndex < teacherRepository.groups.value.count else { return Observable.just([]) }

        let groupCode = teacherRepository.groups.value[groupIndex]
        let classificationId = teacherRepository.classifications.value[classificationIndex]

        return teacherRepository.studentClassifications(course: course.code, groupCode: groupCode.id,
                                                        classificationId: classificationId.identifier)
            .do(onNext: { [weak self] _ in
                self?.dynamicCellViewModels = [] // Reset view models array to clean memory
            })
            // Sort by current sorter selected
            .flatMap { [weak self] classifications -> Observable<[StudentClassification]> in
                guard let self = self else { return Observable.empty() }

                return Observable.combineLatest(self.activeSorterIndex, self.isAscending) { [weak self] sorterIndex, isAscending in
                    guard let sorters = try self?.sorters.value(),
                          sorters.indices.contains(sorterIndex) else { return [] }

                    let sorted = sorters[sorterIndex].sort(classifications, ascending: isAscending)
                    return sorted
                }
            }
            .map { [weak self] (classifications: [StudentClassification]) -> [DynamicValueCellViewModel] in
                guard let self = self else { return [] }

                return classifications.map { (item: StudentClassification) -> DynamicValueCellViewModel in
                    let cellViewModel = DynamicValueCellViewModel(
                        valueType: classification.valueType,
                        evaluationType: classification.evaluationType,
                        key: item.username,
                        title: "\(item.lastName) \(item.firstName)",
                        subtitle: item.username
                    )
                    cellViewModel.value.accept(item.value)
                    self.dynamicCellViewModels.append(cellViewModel)

                    return cellViewModel
                }
            }
    }

    /// Bind selected options
    private func bindOptions() {
        groupSelectedIndex
            .flatMap { [weak self] index -> Observable<String> in
                self?.teacherRepository.groups.map { options in
                    if options.count > index {
                        return options[index].title()
                    }
                    return ""
                } ?? Observable.just("")
            }
            .bind(to: groupsCellViewModel.selectedOption)
            .disposed(by: bag)

        classificationSelectedIndex
            .flatMap { [weak self] index -> Observable<String> in
                self?.teacherRepository.classifications.map { options in
                    if options.count > index {
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
                guard let self = self else { return Observable.just([]) }

                if index == 0 {
                    return self.teacherRepository.groups.map { $0.map { $0.title() } }
                } else if index == 1 {
                    return self.teacherRepository.classifications.map { $0.map { $0.getLocalizedText() } }
                }
                return Observable.just([])
            }
            .bind(to: options)
            .disposed(by: bag)
    }

    /// Submit current value for current index path
    func submitSelectedValue() {
        guard let index = selectedCellIndex.value else { return }

        if index.section == 0, index.item == 0 {
            groupSelectedIndex.accept(selectedOptionIndex.value)
        } else if index.section == 0, index.item == 1 {
            classificationSelectedIndex.accept(selectedOptionIndex.value)
        }
    }
}
