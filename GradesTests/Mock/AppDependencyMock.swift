//
//  AppDependencyMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 27/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

@testable import GradesDev

final class AppDependencyMock: HasNoDependency {
	private init() {}
	static let shared = AppDependencyMock()
	
	let _authService = AuthenticationServiceMock()
	lazy var authService: AuthenticationServiceProtocol = { return _authService }()
	
	let _coordinator = SceneCoordinatorMock()
	lazy var coordinator: SceneCoordinatorType = { _coordinator }()
	
	lazy var httpService: HttpServiceProtocol = HttpServiceMock()
	lazy var pushNotificationsService: PushNotificationServiceProtocol = PushNotificationService(dependencies: self)
	
	let _gradesApi = GradesAPIMock()
	lazy var gradesApi: GradesAPIProtocol = { return _gradesApi }()
	
	lazy var userRepository: UserRepositoryProtocol = UserRepositoryMock(dependencies: self)
	
	lazy var settingsRepository: SettingsRepositoryProtocol = SettingsRepositoryMock()
	lazy var coursesRepository: CoursesRepositoryProtocol = CoursesRepositoryMock()
	
	let _courseRepository = CourseRepositoryMock()
	lazy var courseRepository: CourseRepositoryProtocol = CourseRepositoryMock()
	
	lazy var teacherRepository: TeacherRepositoryProtocol = TeacherRepositoryMock()
}

extension AppDependencyMock: HasSceneCoordinator {}

extension AppDependencyMock: HasAuthenticationService {}
extension AppDependencyMock: HasHttpService {}
extension AppDependencyMock: HasGradesAPI {}
extension AppDependencyMock: HasPushNotificationService {}

extension AppDependencyMock: HasUserRepository {}
extension AppDependencyMock: HasSettingsRepository {}
extension AppDependencyMock: HasCoursesRepository {}
extension AppDependencyMock: HasCourseRepository {}
extension AppDependencyMock: HasTeacherRepository {}
