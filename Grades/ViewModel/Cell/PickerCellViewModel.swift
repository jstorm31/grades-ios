//
//  PickerCellViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 28/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift

struct PickerCellViewModel {
    let title: String
    let selectedOption = BehaviorSubject<String>(value: "")
}
