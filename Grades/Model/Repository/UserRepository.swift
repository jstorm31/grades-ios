//
//  UserRepository.swift
//  Grades
//
//  Created by Jiří Zdvomka on 05/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftKeychainWrapper

protocol UserRepositoryProtocol {
    var user: BehaviorRelay<User?> { get }
}

protocol HasUserRepository {
    var userRepository: UserRepositoryProtocol { get }
}

final class UserRepository: UserRepositoryProtocol {
    typealias Dependencies = HasNoDependency

    let user = BehaviorRelay<User?>(value: nil)

    private let dependencies: Dependencies
    private let keychainWrapper: KeychainWrapper
    private let bag = DisposeBag()

    // MARK: Initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        let config = EnvironmentConfiguration.shared.keychain
        keychainWrapper = KeychainWrapper(serviceName: config.serviceName, accessGroup: config.accessGroup)

        // Save username to keychain for NotificationServiceExtension
        user.unwrap()
            .map { $0.username }
            .subscribe(onNext: { [weak self] username in
                self?.keychainWrapper.set(username, forKey: "username", withAccessibility: .afterFirstUnlock)
            })
            .disposed(by: bag)
    }
}
