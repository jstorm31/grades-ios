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
    let itemSelected = PublishSubject<Int>()
    var onBackAction: CocoaAction!
    private let coordinator: SceneCoordinatorType
    private let bag = DisposeBag()

    // MARK: Initialization

    init(coordinator: SceneCoordinatorType, students: BehaviorRelay<[User]>, selectedStudent: BehaviorSubject<User?>) {
        self.coordinator = coordinator
        super.init()

        onBackAction = CocoaAction { coordinator.didPop().asObservable().map { _ in } }

        students
            .map { $0.map { UserCellConfigurator(item: $0) } }
            .map { [TableSection(header: "", items: $0)] }
            .bind(to: dataSource)
            .disposed(by: bag)

        itemSelected
            .filter { students.value.count > $0 }
            .map { students.value[$0] }
            .do(onNext: { [weak self] _ in self?.coordinator.pop(animated: true) })
            .bind(to: selectedStudent)
            .disposed(by: bag)
    }
}
