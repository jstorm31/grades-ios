//
//  UserRepository.swift
//  Grades
//
//  Created by Jiří Zdvomka on 05/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift

protocol UserRepositoryProtocol {
    var user: BehaviorRelay<User?> { get }
}

protocol HasUserRepository {
    var userRepository: UserRepositoryProtocol { get }
}

final class UserRepository: UserRepositoryProtocol {
    typealias Dependencies = HasNoDependency
    private let dependencies: Dependencies

    let user = BehaviorRelay<User?>(value: nil)

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
