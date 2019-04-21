//
//  FieldArrayViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 20/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift

/**
 Protocol for table ViewModel with array field

 Conforming type can bind cell's ViewModel by provided function bind(cellViewModel:).
 **Conforming type must initialize fieldValeus dictionary with values**
 */
protocol DynamicValueFieldArrayViewModelProtocol {
    typealias FieldsDict = [String: DynamicValue?]
    var fieldValues: BehaviorRelay<FieldsDict> { get }
}

extension DynamicValueFieldArrayViewModelProtocol where Self: BaseViewModel {
    /// Setup bindings with cell's ViewModel
    func bind(cellViewModel: DynamicValueCellViewModel) {
        cellViewModel.value
            // Filter out same values to stop reactive cycle between fieldValues and cell's ViewModel (and to improve performance)
            .filter { [weak self] value in
                guard let `self` = self else { return false }
                return value != (self.fieldValues.value[cellViewModel.key] ?? nil)
            }
            // Map value to fiedlValues array
            .map { [weak self] value -> FieldsDict in
                var values = self?.fieldValues.value ?? [:]
                values[cellViewModel.key] = value
                return values
            }
            .bind(to: fieldValues)
            .disposed(by: cellViewModel.bag)

        // Bind values to cell ViewModel
        fieldValues
            .map { $0[cellViewModel.key] ?? nil }
            .bind(to: cellViewModel.value)
            .disposed(by: cellViewModel.bag)
    }
}
