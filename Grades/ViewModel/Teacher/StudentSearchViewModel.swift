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
    let dataSource = BehaviorSubject<[TableSection]>(value: [])
    private let coordinator: SceneCoordinatorType
    private let bag = DisposeBag()

    lazy var onBackAction = CocoaAction { [weak self] in
        self?.coordinator.didPop()
            .asObservable().map { _ in } ?? Observable.empty()
    }

    // MARK: Initialization

    init(coordinator: SceneCoordinatorType, students: BehaviorRelay<[User]>) {
        self.coordinator = coordinator

        students
            .map { $0.map { UserCellConfigurator(item: $0) } }
            .map { [TableSection(header: "", items: $0)] }
            .bind(to: dataSource)
            .disposed(by: bag)
    }
}
