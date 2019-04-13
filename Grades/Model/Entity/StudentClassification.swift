//
//  StudentClassification.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

struct StudentClassification {
    var classificationIdentifier: String
    var firstName: String?
    var lastName: String?
    var username: String
    var value: DynamicValue?
}

extension StudentClassification: Codable {
    enum CodingKeys: String, CodingKey {
        case classificationIdentifier, firstName, lastName, value
        case username = "studentUsername"
    }
}
