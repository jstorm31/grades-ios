//
//  BaseViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

class BaseViewModel {
    init() {
        Log.info("Allocated ViewModel: \(self)")
    }

    deinit {
        Log.info("Deallocated ViewModel: \(self)")
    }
}
