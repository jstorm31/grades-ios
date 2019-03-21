//
//  Subject.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxDataSources

// TODO: refactor to use only GradesAPI dependency

/// Raw course representation for decoding from JSON
struct RawCourse: Decodable {
    var code: String
    var items: [OverviewItem]

    enum CodingKeys: String, CodingKey {
        case code = "courseCode"
        case items = "overviewItems"
    }
}

struct CourseDetail: Decodable {
    var code: String
    var name: String?

    enum CodingKeys: String, CodingKey {
        case code = "courseCode"
        case name = "courseName"
    }
}

struct RawKosCourse: Decodable {
    var name: String
}

struct Course {
    var code: String
    var name: String?
    var finalValue: DynamicValue?

    init(code: String, finalValue: DynamicValue? = nil) {
        self.code = code
        self.finalValue = finalValue
    }

    init(fromCourse course: Course) {
        code = course.code
        name = course.name
        finalValue = course.finalValue
    }

    init(fromRawCourse rawCourse: RawCourse) {
        code = rawCourse.code
        if let overviewItem = rawCourse.items.first(where: { $0.type == "POINTS_TOTAL" }),
            let value = overviewItem.value {
            finalValue = value
        } else if let overviewItem = rawCourse.items.first(where: { $0.type == "FINAL_SCORE" }),
            let value = overviewItem.value {
            finalValue = value
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
