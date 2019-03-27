//
//  AppDependencyMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 27/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

@testable import GradesDev

final class AppDependencyMock: AppDependencyProtocol {
	private init() {}
	static let shared = AppDependencyMock()
	
	lazy var authService: AuthenticationServiceProtocol = AuthenticationServiceMock()
	lazy var httpService: HttpServiceProtocol = HttpServiceMock()
	lazy var gradesApi: GradesAPIProtocol = GradesAPIMock()
	
	lazy var settingsRepository: SettingsRepositoryProtocol = SettingsRepositoryMock()
	lazy var coursesRepository: CoursesRepositoryProtocol = CoursesRepositoryMock()
}

extension AppDependencyMock: HasAuthenticationService {}
extension AppDependencyMock: HasHttpService {}
extension AppDependencyMock: HasGradesAPI {}

extension AppDependencyMock: HasSettingsRepository {}
extension AppDependencyMock: HasCoursesRepository {}
