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
    typealias Dependencies = HasSceneCoordinator

    let dataSource = BehaviorSubject<[TableSection]>(value: [])
    let itemSelected = PublishSubject<Int>()
    let searchText = BehaviorSubject<String>(value: "")
    var onBackAction: CocoaAction!
    private let dependencies: Dependencies
    private let bag = DisposeBag()

    // MARK: Initialization

    init(dependencies: Dependencies, students: BehaviorRelay<[User]>, selectedStudent: BehaviorRelay<User?>) {
        self.dependencies = dependencies
        super.init()

        onBackAction = CocoaAction { [weak self] in
            self?.dependencies.coordinator.didPop().asObservable().map { _ in } ?? Observable.empty()
        }

        // Filter students and bind it to dataSource
        let filteredStudents = Observable.combineLatest(students, searchText) { ($0, $1) }
            .map { arg -> [User] in
                let (students, text) = arg
                return text.isEmpty ? students : students.filter { $0.contains(text.lowercased()) }
            }
            .share(replay: 1, scope: .whileConnected)

        filteredStudents
            .map { $0.map { UserCellConfigurator(item: $0) } }
            .map { [TableSection(header: "", items: $0)] }
            .bind(to: dataSource)
            .disposed(by: bag)

        // Bind selected item
        let selected = itemSelected
            .flatMap { index in
                filteredStudents.map { $0[index] }
            }
            .share()

        selected.bind(to: selectedStudent).disposed(by: bag)

        selected.take(1).subscribe(onNext: { [weak self] _ in
            self?.dependencies.coordinator.pop()
        }).disposed(by: bag)
    }
}
