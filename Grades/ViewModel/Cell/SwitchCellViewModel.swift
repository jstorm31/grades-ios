//
//  SwitchCellViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 26/09/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa

struct SwitchCellViewModel {
    let title: String
    let isEnabled: BehaviorRelay<Bool>
}
