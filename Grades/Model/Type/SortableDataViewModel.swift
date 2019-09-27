//
//  SortableDataViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 21/08/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift

protocol SortableDataViewModel {
    var sorters: BehaviorSubject<[StudentClassificationSorter]> { get }
    var activeSorterIndex: BehaviorSubject<Int> { get }
}
