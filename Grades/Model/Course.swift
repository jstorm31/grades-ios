//
//  Subject.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxDataSources

/// Raw course representation for decoding from JSON
struct RawCourse: Decodable {
    var code: String
    var items: [OverviewItem]

    enum CodingKeys: String, CodingKey {
        case code = "courseCode"
        case items = "overviewItems"
    }
}

struct Course {
    var code: String
    var name: String = "Course name" // TODO: fetch from kosAPI
    var totalPoints: String?

    init(code: String, totalPoints: String? = nil) {
        self.code = code
        self.totalPoints = totalPoints
    }

    init(fromRawCourse rawCourse: RawCourse) {
        Log.debug("RawCourse: \(rawCourse)")
        code = rawCourse.code
        if let overviewItem = rawCourse.items.first(where: { $0.type == "POINTS_TOTAL" }) {
            totalPoints = overviewItem.value
        }
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
