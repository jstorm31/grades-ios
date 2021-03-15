//
//  PickerViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// Class providing logic for multiple pickers with options
class TablePickerViewModel: BaseViewModel {
    private let bag = DisposeBag()

    let selectedCellIndex = BehaviorRelay<IndexPath?>(value: nil)
    let selectedOptionIndex = BehaviorRelay<Int>(value: 0)
    let options = BehaviorSubject<[String]>(value: [])

    func handleOptionChange(cellIndexPath: IndexPath) {
        selectedCellIndex.accept(cellIndexPath)
    }
}
