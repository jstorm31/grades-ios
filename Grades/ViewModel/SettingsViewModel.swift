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

protocol SettingsViewModelProtocol {
    typealias CurrentSetting = (IndexPath, Int)

    var settings: BehaviorRelay<[SettingsSection]> { get }
    var options: BehaviorSubject<[String]> { get }
    var selectedOptionIndex: BehaviorRelay<Int> { get }

    var setCurrentSettingStateAction: Action<CurrentSetting, Void> { get }
    var onBackAction: CocoaAction { get }
    var logoutAction: CocoaAction { get }

    func bindOutput()
    func submitSelectedValue()
}

class SettingsViewModel: BaseViewModel, SettingsViewModelProtocol {
    private let coordinator: SceneCoordinatorType
    private let repository: SettingsRepositoryProtocol
    private let bag = DisposeBag()

    private let selectedSettingIndex = BehaviorRelay<IndexPath?>(value: nil)

    // MARK: output

    let settings = BehaviorRelay<[SettingsSection]>(value: [])
    let options = BehaviorSubject<[String]>(value: [])
    let selectedOptionIndex = BehaviorRelay<Int>(value: 0)

    // MARK: actions

    lazy var setCurrentSettingStateAction: Action<CurrentSetting, Void> = Action { [weak self] settingIndex, optionIndex in
        self?.selectedSettingIndex.accept(settingIndex)
        self?.selectedOptionIndex.accept(optionIndex)
        return Observable.empty()
    }

    lazy var logoutAction = CocoaAction { [weak self] in
        self?.coordinator.pop()
        return Observable.empty()
    }

    lazy var onBackAction = CocoaAction { [weak self] in
        self?.coordinator.didPop()
            .asObservable().map { _ in } ?? Observable.empty()
    }

    // MARK: initialization

    init(coordinator: SceneCoordinatorType, repository: SettingsRepositoryProtocol) {
        self.coordinator = coordinator
        self.repository = repository
        super.init()

        // Bind currently selected options
        selectedSettingIndex
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

    // MARK: methods

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
    func submitSelectedValue() {
        guard let index = self.selectedSettingIndex.value else { return }

        // Semester
        if index.section == 0, index.item == 0 {
            repository.changeSemester(optionIndex: selectedOptionIndex.value)
        }
    }
}
