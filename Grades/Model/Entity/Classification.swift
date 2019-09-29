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
    var identifier: String
    var text: [ClassificationText]
    var evaluationType: EvaluationType
    var type: String?
    var valueType: DynamicValueType
    var value: DynamicValue?
    var parentId: Int?
    var isHidden: Bool = false

    var isDefined: Bool {
        return value != nil
    }

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
        case type = "classificationType"
        case isHidden = "hidden"
        case id, identifier, value, valueType, parentId, evaluationType
    }
}

struct ClassificationText: Codable {
    var identifier: String
    var name: String = ""
}

/// Group of classifications with same type
struct GroupedClassification {
    var id: Int?
    var identifier: String?
    var header: String?
    var type: String?
    var totalValue: DynamicValue?
    var items: [Classification]

    init(fromClassification classification: Classification?, items: [Classification] = []) {
        if let classification = classification {
            id = classification.id
            identifier = classification.identifier
            header = classification.getLocalizedText()
            type = classification.type
            totalValue = classification.value
        }
        self.items = items
    }
}

extension GroupedClassification: SectionModelType {
    typealias Item = Classification

    init(original: GroupedClassification, items: [Item]) {
        self = original
        self.items = items
    }
}
