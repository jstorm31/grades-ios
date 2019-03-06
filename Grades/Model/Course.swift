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

extension Course: Equatable {
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.courseCode == rhs.courseCode && lhs.overviewItems == rhs.overviewItems
    }
}

struct OverviewItem: Codable {
    var classificationType: String
    var value: String?
}

extension OverviewItem: Equatable {
    static func == (lhs: OverviewItem, rhs: OverviewItem) -> Bool {
        return lhs.classificationType == rhs.classificationType && lhs.value == rhs.value
    }
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
}
