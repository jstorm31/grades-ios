//
//  AppDependency.swift
//  Grades
//
//  Created by Jiří Zdvomka on 21/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

protocol HasNoDependency {}

protocol AppDependencyProtocol: HasNoDependency {
    static var shared: Self { get }

    var authService: AuthenticationServiceProtocol { get }
    var httpService: HttpServiceProtocol { get }
    var gradesApi: GradesAPIProtocol { get }

    var settingsRepository: SettingsRepositoryProtocol { get }
    var coursesRepository: CoursesRepositoryProtocol { get }
}

final class AppDependency: AppDependencyProtocol {
    private init() {}
    static let shared = AppDependency()

    lazy var authService: AuthenticationServiceProtocol = AuthenticationService()
    lazy var httpService: HttpServiceProtocol = HttpService(client: self.authService.handler.client)
    lazy var gradesApi: GradesAPIProtocol = GradesAPI(dependencies: self)

    lazy var settingsRepository: SettingsRepositoryProtocol = SettingsRepository(dependencies: self)
    lazy var coursesRepository: CoursesRepositoryProtocol = CoursesRepository(dependencies: self)
}

extension AppDependency: HasAuthenticationService {}
extension AppDependency: HasHttpService {}
extension AppDependency: HasGradesAPI {}

extension AppDependency: HasSettingsRepository {}
extension AppDependency: HasCoursesRepository {}
