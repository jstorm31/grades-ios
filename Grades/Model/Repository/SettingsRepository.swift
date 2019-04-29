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

protocol HasSettingsRepository {
    var settingsRepository: SettingsRepositoryProtocol { get }
}

protocol SettingsRepositoryProtocol {
    var currentSettings: BehaviorRelay<Settings> { get }
    var semesterOptions: BehaviorRelay<[String]> { get }
    var languageOptions: [Language] { get }

    func fetchCurrentSemester() -> Observable<Void>
    func changeSemester(optionIndex index: Int)
    func logout()
}

final class SettingsRepository: SettingsRepositoryProtocol {
    typealias Dependencies = HasAuthenticationService & HasGradesAPI

    private let dependencies: Dependencies
    private let KEY = "Settings"
    private let bag = DisposeBag()
    private var currentSemesterCode: String?

    // MARK: output

    let currentSettings: BehaviorRelay<Settings>
    lazy var semesterOptions = BehaviorRelay<[String]>(value: getSemesterOptions(yearCount: 3))
    let languageOptions: [Language] = [.czech, .english]

    // MARK: init

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        let language = Locale.current.languageCode ?? EnvironmentConfiguration.shared.defaultLanguage
        let defaultLanguage = Language.language(forString: language)

        let defaultSettings = Settings(language: defaultLanguage, semester: currentSemesterCode)
        currentSettings = BehaviorRelay<Settings>(value: defaultSettings)

        if let loadedSettings = loadSettings() {
            currentSettings.accept(loadedSettings)
        }

        updateLocale()
    }

    // MARK: methods

    func fetchCurrentSemester() -> Observable<Void> {
        return dependencies.gradesApi.getCurrentSemestrCode()
            .do(onNext: { [weak self] semesterCode in
                self?.currentSemesterCode = semesterCode
            })
            .map { _ in }
    }

    func changeSemester(optionIndex index: Int) {
        var newSettings = currentSettings.value
        newSettings.semester = semesterOptions.value[index]
        currentSettings.accept(newSettings)
        saveSettings()
    }

    func logout() {
        let client = dependencies.authService.handler.client
        client.credential.oauthToken = ""
        client.credential.oauthRefreshToken = ""
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
    }

    // Generate last x semesters from current semester
    private func getSemesterOptions(yearCount: Int) -> [String] {
        guard let currentSemesterCode = currentSemesterCode else { return [] }

        var semester = currentSemesterCode
        var semesters: [String] = [semester]

        // Remove B from code e.g. "B182"
        semester = semester.replacingOccurrences(of: "B", with: "")

        // Convert to number
        guard var semesterNumber = Int(semester) else { return semesters }

        // If even, add odd semester of this year
        if semesterNumber % 2 == 0 {
            semesters.append("B\(semesterNumber - 1)") // B181
            semesterNumber -= 2 // B180
        } else {
            semesterNumber -= 1 // B180
        }

        // Generate last yearCount years
        guard yearCount > 0 else { return semesters }
        for i in 0 ... yearCount - 1 {
            semesters.append("B\(semesterNumber - 8 - i * 10)")
            semesters.append("B\(semesterNumber - 9 - i * 10)")
        }

        return semesters
    }
}
