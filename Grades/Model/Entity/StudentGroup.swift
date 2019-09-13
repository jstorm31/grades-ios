//
//  StudentGroup.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

struct StudentGroup {
    let id: String
    let name: String
    let description: String?

    func title() -> String {
        return replaceLocalizationStrings(text: name)
    }

    /// Replaces localization keys in name with localized values
    private func replaceLocalizationStrings(text: String) -> String {
        let regex = try? NSRegularExpression(pattern: "\\{([^}]*)\\}")
        guard let result = regex?.matches(in: text, range: NSRange(location: 0, length: text.count)) else {
            return text
        }
        let localizationKeys = result.map { (text as NSString).substring(with: $0.range(at: 1)) }

        var replacedText = text
        for key in localizationKeys {
            let localizedKey = NSLocalizedString(key, tableName: "StudentGroups", comment: "student group")
            replacedText = replacedText.replacingOccurrences(of: "{\(key)}", with: localizedKey)
        }

        return replacedText
    }
}

extension StudentGroup: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "studentGroupId"
        case name, description
    }
}
