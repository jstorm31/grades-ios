//
//  Double+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 14/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

extension Double {
    var cleanValue: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
