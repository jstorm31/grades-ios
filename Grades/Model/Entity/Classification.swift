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
    var rawValue: String?
    var valueType: String?

    enum CodingKeys: String, CodingKey {
        case text = "classificationTextDtos"
        case scope = "aggregationScope"
        case type = "classificationType"
        case rawValue = "value"
        case valueType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        text = try container.decode([ClassificationText].self, forKey: .text)
        scope = try container.decodeIfPresent(String.self, forKey: .scope)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        valueType = try container.decodeIfPresent(String.self, forKey: .valueType)

        // Value for key .value can be either String? or Int?
        // TODO: refactor - https://stackoverflow.com/questions/48007761/how-to-handle-partially-dynamic-json-with-swift-codable
        do {
            rawValue = try container.decodeIfPresent(String.self, forKey: .rawValue)
        } catch {
            let intValue = try container.decode(Int.self, forKey: .rawValue)
            rawValue = String(intValue)
        }
    }
}

struct ClassificationText: Decodable {
    var identifier: String?
    var name: String?
}
