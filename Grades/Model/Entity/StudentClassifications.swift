//
//  CourseDetailed.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

// Object for decoding classifications of student
struct StudentClassifications: Decodable {
    var classifications: [Classification]

    enum CodingKeys: String, CodingKey {
        case classifications = "studentClassificationFullDtos"
    }
}
