//
//  AppDependency.swift
//  Grades
//
//  Created by Jiří Zdvomka on 21/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import FirebaseRemoteConfig

protocol HasNoDependency {}

final class AppDependency: HasNoDependency {
    private init() {}
    static let shared = AppDependency()

    lazy var coordinator: SceneCoordinatorType = SceneCoordinator() // Do not forget to set root view controller in AppDelegate

    lazy var remoteConfigService: RemoteConfigServiceProtocol = RemoteConfigService(self)
    lazy var authService: AuthenticationServiceProtocol = AuthenticationService(dependencies: self)
    lazy var httpService: HttpServiceProtocol = HttpService(dependencies: self)
    lazy var gradesApi: GradesAPIProtocol = remoteConfigService.mockData.value ? GradesAPIMock() : GradesAPI(dependencies: self)
    lazy var pushNotificationsService: PushNotificationServiceProtocol = PushNotificationService(dependencies: self)

    lazy var userRepository: UserRepositoryProtocol = UserRepository(dependencies: self)
    lazy var settingsRepository: SettingsRepositoryProtocol = SettingsRepository(dependencies: self)
    lazy var coursesRepository: CoursesRepositoryProtocol = CoursesRepository(dependencies: self)
    lazy var courseRepository: CourseRepositoryProtocol = CourseRepository(dependencies: self)
    lazy var teacherRepository: TeacherRepositoryProtocol = TeacherRepository(dependencies: self)
}

extension AppDependency: HasSceneCoordinator {}

extension AppDependency: HasRemoteConfigService {}
extension AppDependency: HasAuthenticationService {}
extension AppDependency: HasHttpService {}
extension AppDependency: HasGradesAPI {}
extension AppDependency: HasPushNotificationService {}

extension AppDependency: HasUserRepository {}
extension AppDependency: HasSettingsRepository {}
extension AppDependency: HasCoursesRepository {}
extension AppDependency: HasCourseRepository {}
extension AppDependency: HasTeacherRepository {}
