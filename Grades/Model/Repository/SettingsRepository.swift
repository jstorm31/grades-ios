//
//  SettingsRepository.swift
//  Grades
//
//  Created by Jiří Zdvomka on 17/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

protocol SettingsRepositoryProtocol {
    var currentSettings: Settings! { get }
}

class SettingsRepository: SettingsRepositoryProtocol {
    private let KEY = "Settings"
    var currentSettings: Settings!

    init() {
        if let loadedSettings = loadSettings() {
            currentSettings = loadedSettings
        } else {
            let language = Locale.current.languageCode ?? EnvironmentConfiguration.shared.defaultLanguage
            currentSettings = Settings(language: language, semestr: nil)
        }

        // Set locale
        UserDefaults.standard.set([currentSettings.language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    /// Load settings from user defaults or use default
    private func loadSettings() -> Settings? {
        if let saved = UserDefaults.standard.object(forKey: KEY) as? Data {
            guard let loaded = try? JSONDecoder().decode(Settings.self, from: saved) else { return nil }
            return loaded
        } else {
            return nil
        }
    }

    /// Save current settings to user defaults
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(currentSettings) {
            UserDefaults.standard.set(encoded, forKey: KEY)
        }
    }
}
