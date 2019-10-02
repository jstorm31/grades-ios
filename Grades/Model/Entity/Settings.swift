//
//  Settings.swift
//  Grades
//
//  Created by Jiří Zdvomka on 17/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

/// Model for settings
struct Settings: Codable {
    var language: Language
    var semester: String?
    var sendingNotificationsEnabled: Bool = true
    var undefinedEvaluationHidden: Bool = false
}

/// Struct for settings view
struct SettingsView {
    let name: String
    let roles: String
    let options: PickerCellViewModel
    let sendingNotificationsEnabled: SwitchCellViewModel?
    let undefinedEvaluationHidden: SwitchCellViewModel?
}
