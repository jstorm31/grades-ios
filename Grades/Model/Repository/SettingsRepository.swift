//
//  SettingsRepository.swift
//  Grades
//
//  Created by Jiří Zdvomka on 17/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

class SettingsRepository {
    private let KEY = "Settings"
    var currentSettings: Settings!

    init() {
        if let loadedSettings = loadSettings() {
            currentSettings = loadedSettings
            Log.info("Loaded from user defaults")
        } else {
            currentSettings = Settings(semestr: "BI-182", language: "cs")
            Log.info("Loaded default settings")
        }
    }

    /// Load settings from user defaults or use default
    func loadSettings() -> Settings? {
        if let saved = UserDefaults.standard.object(forKey: KEY) as? Data {
            guard let loaded = try? JSONDecoder().decode(Settings.self, from: saved) else { return nil }
            return loaded
        } else {
            return nil
        }
    }

    /// Save current settings to user defaults
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(currentSettings) {
            UserDefaults.standard.set(encoded, forKey: KEY)
        }
    }
}
