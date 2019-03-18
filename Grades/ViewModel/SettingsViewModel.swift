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

    var onBack: CocoaAction

    init(coordinator: SceneCoordinatorType, repository: SettingsRepositoryProtocol) {
        self.coordinator = coordinator
        self.repository = repository

        onBack = CocoaAction {
            coordinator.didPop()
                .asObservable().map { _ in }
        }

        super.init()
    }
}
