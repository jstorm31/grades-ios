//
//  BaseViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

class BaseViewModel {
    init() {
        #if DEBUG
            NSLog("ℹ️ Allocated ViewModel: \(self)")
        #endif
    }

    deinit {
        #if DEBUG
            NSLog("ℹ️ Dealllocated ViewModel: \(self)")
        #endif
    }
}
