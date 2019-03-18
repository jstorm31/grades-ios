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
    var selectedValue = BehaviorRelay<String?>(value: nil)
    var onOptionSelected: CocoaAction

    init(coordinator: SceneCoordinatorType, repository: SettingsRepositoryProtocol) {
        self.coordinator = coordinator
        self.repository = repository

        onBack = CocoaAction {
            coordinator.didPop()
                .asObservable().map { _ in }
        }

        onOptionSelected = CocoaAction {
            Log.info("Done clicked")
            return Observable.empty()
        }

        super.init()

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
        let settingsData: [SettingsSection] = [
            SettingsSection(header: L10n.Settings.user, items: [
                .text(title: "Text", text: "Hodnota!"),
            ]),
            SettingsSection(header: L10n.Settings.options, items: [
                .picker(title: "Picker 1", options: ["First", "Second", "Third"], value: "Juchůů"),
                .picker(title: "Picker 2", options: ["1", "2", "3"], value: "Select")
            ])
        ]

        settings.accept(settingsData)
    }
}
