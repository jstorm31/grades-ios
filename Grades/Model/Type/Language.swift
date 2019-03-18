//
//  Language.swift
//  Grades
//
//  Created by Jiří Zdvomka on 18/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

enum Language: String, Codable {
    case czech = "cs"
    case english = "en"

    static func language(forString string: String) -> Language {
        switch string {
        case Language.czech.rawValue:
            return Language.czech
        case Language.english.rawValue:
            return Language.english
        default:
            return Language.english
        }
    }
}
