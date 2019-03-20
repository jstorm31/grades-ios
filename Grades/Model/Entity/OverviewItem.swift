//
//  OverviewItem.swift
//  Grades
//
//  Created by Jiří Zdvomka on 08/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

struct OverviewItem: Decodable {
    var type: String
    var value: String?

    enum CodingKeys: String, CodingKey {
        case type = "classificationType"
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        type = try container.decode(String.self, forKey: .type)

        // Value for key .value can be either String? or Int?
        do {
            value = try container.decodeIfPresent(String.self, forKey: .value)
        } catch {
            // TODO: refactor to use dynamic value
            let intValue = try container.decode(Int.self, forKey: .value)
            value = String(intValue)
        }
    }

    init(type: String, value: String?) {
        self.type = type
        self.value = value
    }
}
