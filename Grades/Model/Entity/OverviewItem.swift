//
//  OverviewItem.swift
//  Grades
//
//  Created by Jiří Zdvomka on 08/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

struct OverviewItem {
    var type: String
    var value: DynamicValue?
}

extension OverviewItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case type = "classificationType"
        case value
    }
}
