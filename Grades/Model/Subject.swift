//
//  Subject.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

struct Subject: Codable {
    var courseCode: String
    var overviewItems: [OverviewItem]
}

struct OverviewItem: Codable {
    var classificationType: String
    var value: String?
}
