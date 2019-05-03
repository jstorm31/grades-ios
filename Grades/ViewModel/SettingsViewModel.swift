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
    typealias Dependencies = HasSettingsRepository & HasPushNotificationService

    private var dependencies: Dependencies
    private let coordinator: SceneCoordinatorType
    private let bag = DisposeBag()

    private let semesterSelectedIndex = BehaviorRelay<Int>(value: 0)
    private let semesterCellViewModel = PickerCellViewModel(title: L10n.Settings.semester)

    // MARK: output

    let settings = BehaviorRelay<[TableSection]>(value: [])

    lazy var selectedCellOptionIndex: Observable<Int> = {
        selectedCellIndex
            .unwrap()
            .filter { $0.section == 0 }
            .map { $0.item }
            .flatMap { [weak self] _ -> Observable<Int> in
                self?.semesterSelectedIndex.asObservable() ?? Observable.just(0)
            }
            .share()
    }()

    // MARK: actions

    lazy var logoutAction = CocoaAction { [weak self] in
        guard let `self` = self else { return Observable.empty() }

        return self.dependencies.pushNotificationsService.unregisterUserFromDevice()
            .do(onCompleted: { [weak self] in
                self?.coordinator.pop(animated: true, presented: true)
            })
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
    }

    // MARK: methods

    func bindOutput() {
        // Data source
        semesterSelectedIndex
            .map { [weak self] _ in
                guard let `self` = self else { return [] }

                return [
                    TableSection(header: L10n.Settings.options, items: [
                        PickerCellConfigurator(item: self.semesterCellViewModel)
                    ])
                ]
            }
            .bind(to: settings)
            .disposed(by: bag)

        // Initial value of semester
        let sharedSettings = dependencies.settingsRepository.currentSettings.share()

        sharedSettings
            .map { $0.semester }
            .unwrap()
            .flatMap { [weak self] semester -> Observable<Int> in
                self?.dependencies.settingsRepository.semesterOptions.map { $0.firstIndex(of: semester) ?? 0 } ?? Observable.just(0)
            }
            .bind(to: semesterSelectedIndex)
            .disposed(by: bag)

        //		sharedSettings.map {  }

        bindOptions()
    }

    func bindOptions() {
        // Bind selected semester title
        semesterSelectedIndex
            .flatMap { [weak self] index -> Observable<String> in
                self?.dependencies.settingsRepository.semesterOptions.map { options in
                    if options.count - 1 > index {
                        return options[index]
                    }
                    return ""
                } ?? Observable.just("")
            }
            .bind(to: semesterCellViewModel.selectedOption)
            .disposed(by: bag)

        // Bind options
        selectedCellIndex
            .unwrap()
            .filter { $0.section == 0 }
            .map { $0.item }
            .flatMap { [weak self] index -> Observable<[String]> in
                guard let `self` = self else { return Observable.just([]) }

                if index == 0 {
                    return self.dependencies.settingsRepository.semesterOptions.asObservable()
                }
                return Observable.just([])
            }
            .bind(to: options)
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
