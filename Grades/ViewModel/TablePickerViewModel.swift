//
//  PickerViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift

/// Class providing logic for multiple pickers with options
class TablePickerViewModel: BaseViewModel {
    private let bag = DisposeBag()

    let selectedCellIndex = BehaviorRelay<IndexPath?>(value: nil)
    let selectedOptionIndex = BehaviorRelay<Int>(value: 0)
    let options = BehaviorSubject<[String]>(value: [])

    func bindOptions(dataSource: BehaviorRelay<[TableSectionPolymorphic]>) {
        selectedCellIndex
            .map { [weak self] indexPath in
                guard self != nil, let indexPath = indexPath else { return [] }
                let item = dataSource.value[indexPath.section].items[indexPath.item]

                if case let .picker(_, options, _) = item {
                    return options
                }

                return []
            }
            .bind(to: options)
            .disposed(by: bag)
    }

    func handleOptionChange(cellIndexPath: IndexPath, optionIndex: Int) {
        selectedCellIndex.accept(cellIndexPath)
        selectedOptionIndex.accept(optionIndex)
    }
}
