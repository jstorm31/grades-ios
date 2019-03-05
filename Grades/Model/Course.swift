//
//  Subject.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxDataSources

struct Course: Codable {
    var courseCode: String
    var overviewItems: [OverviewItem]
}

struct OverviewItem: Codable {
    var classificationType: String
    var value: String?
}

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

    init(header: String) {
        self.header = header
        items = []
    }
}
