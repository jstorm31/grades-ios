//
//  SettingsViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 18/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxCocoa
import RxSwift

class SettingsViewModel: BaseViewModel {
    private let coordinator: SceneCoordinatorType
    private let repository: SettingsRepositoryProtocol
    private let bag = DisposeBag()

    // MARK: output

    var settings = BehaviorRelay<[SettingsSection]>(value: [])
    var options = BehaviorSubject<[String]>(value: [])
    var onBack: CocoaAction

    // MARK: input

    var selectedIndex = BehaviorRelay<IndexPath?>(value: nil)
    var selectedOptionIndex = BehaviorRelay<Int>(value: 0)

    // MARK: methods

    init(coordinator: SceneCoordinatorType, repository: SettingsRepositoryProtocol) {
        self.coordinator = coordinator
        self.repository = repository

        onBack = CocoaAction {
            coordinator.didPop()
                .asObservable().map { _ in }
        }

        super.init()

        // Bind currently selected options
        selectedIndex
            .map { [weak self] indexPath in
                guard
                    let indexPath = indexPath,
                    let item = self?.settings.value[indexPath.section].items[indexPath.item]
                else { return [] }

                if case let .picker(_, options, _) = item {
                    return options
                }
                return []
            }
            .bind(to: options)
            .disposed(by: bag)
    }

    func bindOutput() {
        Observable.combineLatest(repository.currentSettings, repository.semesterOptions) { settings, semesterOptions in
            let semesterValueIndex = semesterOptions.firstIndex { $0 == settings.semester } ?? 0

            return [
                SettingsSection(header: L10n.Settings.options, items: [
                    .picker(title: L10n.Settings.semester, options: semesterOptions, valueIndex: semesterValueIndex)
                ])
            ]
        }
        .bind(to: settings)
        .disposed(by: bag)
    }

    /// Submit current value for current index path
    func submitCurrentValue() {
        guard let index = self.selectedIndex.value else { return }

        // Semester
        if index.section == 0, index.item == 0 {
            repository.changeSemester(optionIndex: selectedOptionIndex.value)
        }
    }
}
