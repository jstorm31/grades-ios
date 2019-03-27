//
//  SettingsRepositoryMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 27/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import RxCocoa
@testable import GradesDev

final class SettingsRepositoryMock: SettingsRepositoryProtocol {
	private var semesterOptionIndex = 0
	
	var currentSettings = BehaviorRelay<Settings>(value: Settings(language: .english, semester: "B182"))
	var semesterOptions = BehaviorRelay<[String]>(value: ["B181", "B180", "B171"])
	
	var languageOptions: [Language] = [.czech, .english]
	
	func fetchCurrentSemester() -> Observable<Void> {
		return Observable.empty()
	}
	
	func changeSemester(optionIndex index: Int) {
		var newSettings = currentSettings.value
		newSettings.semester = semesterOptions.value[index]
		currentSettings.accept(newSettings)
	}
	
	func logout() {}	
}
