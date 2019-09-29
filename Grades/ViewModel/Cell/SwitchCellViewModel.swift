//
//  SwitchCellViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 26/09/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa

final class SwitchCellViewModel {
    let title: String
    let isEnabled: BehaviorRelay<Bool>

    init(title: String, isEnabled: Bool) {
        self.title = title
        self.isEnabled = BehaviorRelay<Bool>(value: isEnabled)
    }
}
