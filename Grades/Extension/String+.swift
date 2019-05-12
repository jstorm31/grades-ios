//
//  String+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

extension String {
    var safeStringByRemovingPercentEncoding: String {
        return removingPercentEncoding ?? self
    }

    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return formatter.date(from: self)
    }
}
