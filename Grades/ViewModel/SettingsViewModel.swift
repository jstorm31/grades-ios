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

class SettingsViewModel: TablePickerViewModel {
    typealias Dependencies = HasSettingsRepository

    private let dependencies: Dependencies
    private let coordinator: SceneCoordinatorType
    private let bag = DisposeBag()

    // MARK: output

    let settings = BehaviorRelay<[TableSection]>(value: [])

    // MARK: actions

    lazy var logoutAction = CocoaAction { [weak self] in
        self?.coordinator.pop()
        return Observable.empty()
    }

    lazy var onBackAction = CocoaAction { [weak self] in
        self?.coordinator.didPop()
            .asObservable().map { _ in } ?? Observable.empty()
    }

    // MARK: initialization

    init(coordinator: SceneCoordinatorType, dependencies: Dependencies) {
        self.dependencies = dependencies
        self.coordinator = coordinator
        super.init()

        bindOptions(dataSource: settings)
    }

    // MARK: methods

    func bindOutput() {
        Observable.combineLatest(
            dependencies.settingsRepository.currentSettings,
            dependencies.settingsRepository.semesterOptions
        ) { settings, semesterOptions in
            let semesterValueIndex = semesterOptions.firstIndex { $0 == settings.semester } ?? 0

            return [
                TableSection(header: L10n.Settings.options, items: [
                    .picker(title: L10n.Settings.semester, options: semesterOptions.map { $0 }, valueIndex: semesterValueIndex)
                ])
            ]
        }
        .bind(to: settings)
        .disposed(by: bag)
    }

    /// Submit current value for current index path
    func submitSelectedValue() {
        guard let index = self.selectedCellIndex.value else { return }

        // Semester
        if index.section == 0, index.item == 0 {
            dependencies.settingsRepository.changeSemester(optionIndex: selectedOptionIndex.value)
        }
    }
}
