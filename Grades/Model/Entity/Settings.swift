//
//  Settings.swift
//  Grades
//
//  Created by Jiří Zdvomka on 17/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxDataSources

struct Settings: Codable {
    var language: Language
    var semester: String
}

// Table view model

enum SettingsItem {
    case text(title: String, text: String)
    case picker(title: String, options: [String], valueIndex: Int)
}

struct SettingsSection {
    var header: String
    var items: [SettingsItem]
}

extension SettingsSection: SectionModelType {
    typealias Item = SettingsItem

    init(original: SettingsSection, items: [Item]) {
        self = original
        self.items = items
    }
}
