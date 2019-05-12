//
//  Date+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 12/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return formatter.string(from: self)
    }
}
