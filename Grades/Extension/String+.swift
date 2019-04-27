//
//  String+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

extension String {
    var safeStringByRemovingPercentEncoding: String {
        return removingPercentEncoding ?? self
    }
}
