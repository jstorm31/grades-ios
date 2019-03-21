//
//  AppDependency.swift
//  Grades
//
//  Created by Jiří Zdvomka on 21/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

protocol HasNoDependency {}

final class AppDependency: HasNoDependency {
    private init() {}
    static let shared = AppDependency()

    lazy var authService: AuthenticationServiceProtocol = AuthenticationService()
    lazy var httpService: HttpServiceProtocol = HttpService(client: self.authService.handler.client)
    lazy var gradesApi: GradesAPIProtocol = GradesAPI(httpService: self.httpService)
}

extension AppDependency: HasAuthenticationService {}
extension AppDependency: HasHttpService {}
extension AppDependency: HasGradesAPI {}
