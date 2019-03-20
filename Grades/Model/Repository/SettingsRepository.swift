//
//  SettingsRepository.swift
//  Grades
//
//  Created by Jiří Zdvomka on 17/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import OAuthSwift
import RxCocoa
import RxSwift

protocol SettingsRepositoryProtocol {
    var currentSettings: BehaviorRelay<Settings> { get }
    var semesterOptions: BehaviorRelay<[String]> { get }
    var languageOptions: [Language] { get }

    func changeSemester(optionIndex index: Int)
    func logout()
}

class SettingsRepository: SettingsRepositoryProtocol {
    private let KEY = "Settings"
    private let authClient: OAuthSwiftClient

    // MARK: output

    var currentSettings: BehaviorRelay<Settings>
    var semesterOptions = BehaviorRelay<[String]>(value: ["B171", "B172", "B182"]) // TODO: replace with dynamic values
    let languageOptions: [Language] = [.czech, .english] // TODO: add from config

    // MARK: init

    init(authClient: OAuthSwiftClient) {
        self.authClient = authClient

        let language = Locale.current.languageCode ?? EnvironmentConfiguration.shared.defaultLanguage
        let defaultLanguage = Language.language(forString: language)

        let defaultSettings = Settings(language: defaultLanguage, semester: "B182")
        currentSettings = BehaviorRelay<Settings>(value: defaultSettings) // TODO: replace with dynamic value

        if let loadedSettings = loadSettings() {
            currentSettings.accept(loadedSettings)
        }

        updateLocale()
    }

    // MARK: methods

    func changeSemester(optionIndex index: Int) {
        var newSettings = currentSettings.value
        newSettings.semester = semesterOptions.value[index]
        currentSettings.accept(newSettings)
        saveSettings()
    }

    func logout() {
        authClient.credential.oauthToken = ""
        authClient.credential.oauthRefreshToken = ""
    }

    // MARK: support methods

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
        if let encoded = try? JSONEncoder().encode(currentSettings.value) {
            UserDefaults.standard.set(encoded, forKey: KEY)
        }
    }

    private func updateLocale() {
        UserDefaults.standard.set([currentSettings.value.language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}
