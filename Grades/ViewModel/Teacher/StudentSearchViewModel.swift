//
//  StudentSearchViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 21/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxCocoa
import RxDataSources
import RxSwift

final class StudentSearchViewModel: BaseViewModel {
    private let coordinator: SceneCoordinatorType

    lazy var onBackAction = CocoaAction { [weak self] in
        self?.coordinator.didPop()
            .asObservable().map { _ in } ?? Observable.empty()
    }

    init(coordinator: SceneCoordinatorType) {
        self.coordinator = coordinator
    }
}
