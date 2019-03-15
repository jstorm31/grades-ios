//
//  Classification.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxDataSources

struct Classification {
    var id: Int
    var text: [ClassificationText]
    var scope: String?
    var type: String?
    var valueType: DynamicValueType
    var value: DynamicValue?
    var parentId: Int?
    var isHidden: Bool = false

    func getLocalizedText() -> String {
        if text.isEmpty {
            return ""
        }

        if let localizedText = text.first(where: { $0.identifier == Locale.current.languageCode }) {
            return localizedText.name
        } else {
            return text[0].name
        }
    }
}

extension Classification: Codable {
    enum CodingKeys: String, CodingKey {
        case text = "classificationTextDtos"
        case scope = "aggregationScope"
        case type = "classificationType"
        case isHidden = "hidden"
        case id, value, valueType, parentId
    }
}

struct ClassificationText: Codable {
    var identifier: String
    var name: String = ""
}

struct GroupedClassification {
    var id: Int
    var header: String
    var totalValue: DynamicValue?
    var items: [Classification]
}

extension GroupedClassification: SectionModelType {
    typealias Item = Classification

    init(original: GroupedClassification, items: [Item]) {
        self = original
        self.items = items
    }
}