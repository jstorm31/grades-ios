//
//  Classification.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

struct Classification: Decodable {
    var text: [ClassificationText]
    var scope: String?
    var type: String?
    var valueType: DynamicValueType
    var value: DynamicValue?

    enum CodingKeys: String, CodingKey {
        case text = "classificationTextDtos"
        case scope = "aggregationScope"
        case type = "classificationType"
        case value, valueType
    }
}

struct ClassificationText: Decodable {
    var identifier: String?
    var name: String?
}
