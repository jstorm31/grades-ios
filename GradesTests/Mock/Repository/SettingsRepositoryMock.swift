//
//  SettingsRepositoryMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 27/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import RxCocoa
@testable import Grades

final class SettingsRepositoryMock: SettingsRepositoryProtocol {
	private var semesterOptionIndex = 0
	
    private let settings = Settings(language: .english,
                                    semester: "B182",
                                    sendingNotificationsEnabled: false,
                                    undefinedEvaluationHidden: false)
	var semesterOptions = BehaviorRelay<[String]>(value: ["B181", "B180", "B171"])
	
    var currentSettings = BehaviorRelay<Settings>(value: Settings(language: .english,
                                                                  semester: "B182",
                                                                  sendingNotificationsEnabled: false,
                                                                  undefinedEvaluationHidden: false))
	
	var languageOptions: [Language] = [.czech, .english]
	
	func fetchCurrentSemester() -> Observable<Void> {
		currentSettings.accept(settings)
		return Observable.just(Void())
	}
	
	func changeSemester(optionIndex index: Int) {
		var newSettings = currentSettings.value
		newSettings.semester = semesterOptions.value[index]
		currentSettings.accept(newSettings)
	}
	
	func logout() {}	
}
