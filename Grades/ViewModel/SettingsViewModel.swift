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
    typealias Dependencies = HasSettingsRepository & HasPushNotificationService & HasUserRepository
        & HasAuthenticationService & HasSceneCoordinator

    private var dependencies: Dependencies
    private let bag = DisposeBag()

    private let semesterSelectedIndex = BehaviorRelay<Int>(value: 0)
    private let semesterCellViewModel = PickerCellViewModel(title: L10n.Settings.semester)

    // MARK: output

    let settings = BehaviorRelay<SettingsView?>(value: nil)

    lazy var selectedCellOptionIndex: Observable<Int> = {
        selectedCellIndex
            .unwrap()
            .filter { $0.section == 1 }
            .map { $0.item }
            .flatMap { [weak self] _ -> Observable<Int> in
                self?.semesterSelectedIndex.asObservable() ?? Observable.just(0)
            }
            .share()
    }()

    // MARK: actions

    lazy var logoutAction = CocoaAction { [weak self] in
        guard let self = self else { return Observable.empty() }

        self.dependencies.authService.logOut()
        return self.dependencies.pushNotificationsService.unregisterUserFromDevice()
            .do(onNext: { [weak self] in
                self?.dependencies.coordinator.pop(animated: true, presented: true)
            })
    }

    lazy var onBackAction = CocoaAction { [weak self] in
        self?.dependencies.coordinator.didPop()
            .asObservable().map { _ in } ?? Observable.empty()
    }

    lazy var onLinkSelectedAction = Action<Int, Void> { [weak self] index in
        guard let self = self else { return Observable.empty() }

        let viewModel = TextViewModel(dependencies: AppDependency.shared, type: TextScene.text(forIndex: index))
        return self.dependencies.coordinator.transition(to: .text(viewModel), type: .push)
            .asObservable().map { _ in }
    }

    // MARK: initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init()
    }

    // MARK: methods

    func bindOutput() {
        // Data source
        semesterSelectedIndex
            .flatMap { [weak self] _ in
                self?.dependencies.userRepository.user.unwrap() ?? Observable.empty()
            }
            .flatMap { [weak self] user in
                self?.dependencies.settingsRepository.currentSettings
                    .map { (user, $0) } ?? Observable.empty()
            }
            .map { [weak self] user, settings in
                guard let self = self else { return nil }

                return SettingsView(name: user.toString,
                                    roles: user.roles.map { $0.toString() }.joined(separator: ", "),
                                    options: self.semesterCellViewModel,
                                    sendingNotificationsEnabled: settings.sendingNotificationsEnabled)
            }
            .unwrap()
            .bind(to: settings)
            .disposed(by: bag)

        // Initial value of semester
        dependencies.settingsRepository.currentSettings
            .map { $0.semester }
            .unwrap()
            .flatMap { [weak self] semester -> Observable<Int> in
                self?.dependencies.settingsRepository.semesterOptions.map { $0.firstIndex(of: semester) ?? 0 } ?? Observable.just(0)
            }
            .bind(to: semesterSelectedIndex)
            .disposed(by: bag)

        bindOptions()
    }

    func bindOptions() {
        // Bind selected semester title
        semesterSelectedIndex
            .flatMap { [weak self] index -> Observable<String> in
                self?.dependencies.settingsRepository.semesterOptions.map { options in
                    if options.count > index {
                        return options[index]
                    }
                    Log.error("Option index \(index) out of range")
                    return ""
                } ?? Observable.just("")
            }
            .bind(to: semesterCellViewModel.selectedOption)
            .disposed(by: bag)

        // Bind options
        selectedCellIndex
            .unwrap()
            .filter { $0.section == 1 }
            .map { $0.item }
            .flatMap { [weak self] index -> Observable<[String]> in
                guard let self = self else { return Observable.just([]) }

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
        if index.section == 1, index.item == 0 {
            dependencies.settingsRepository.changeSemester(optionIndex: selectedOptionIndex.value)
        }
    }
}
