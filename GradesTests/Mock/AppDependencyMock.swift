//
//  AppDependencyMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 27/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

@testable import GradesDev

final class AppDependencyMock {
	private init() {}
	static let shared = AppDependencyMock()
	
	let _authService = AuthenticationServiceMock()
	lazy var authService: AuthenticationServiceProtocol = { return _authService }()
	
	lazy var httpService: HttpServiceProtocol = HttpServiceMock()
	
	let _gradesApi = GradesAPIMock()
	lazy var gradesApi: GradesAPIProtocol = { return _gradesApi }()
	
	lazy var settingsRepository: SettingsRepositoryProtocol = SettingsRepositoryMock()
	lazy var coursesRepository: CoursesRepositoryProtocol = CoursesRepositoryMock()
}

extension AppDependencyMock: HasAuthenticationService {}
extension AppDependencyMock: HasHttpService {}
extension AppDependencyMock: HasGradesAPI {}

extension AppDependencyMock: HasSettingsRepository {}
extension AppDependencyMock: HasCoursesRepository {}

extension AppDependencyMock: HasCourseRepositoryProtocol {
	var courseStudentRepositoryFactory: CourseStudentRepositoryFactory {
		return { username, course in
			CourseRepository(dependencies: self, username: username, course: course)
		}
	}
}
