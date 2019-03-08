//
//  Subject.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxDataSources

struct Course: Codable {
    var code: String
    var items: [OverviewItem]

    enum CodingKeys: String, CodingKey {
        case code = "courseCode"
        case items = "overviewItems"
    }
}

/// Type for grouping courses
struct CourseGroup {
    var header: String
    var items: [Course]
}

extension CourseGroup: SectionModelType {
    typealias Item = Course

    init(original: CourseGroup, items: [Item]) {
        self = original
        self.items = items
    }
}
