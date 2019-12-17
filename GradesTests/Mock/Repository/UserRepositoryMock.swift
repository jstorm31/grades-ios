//
//  UserRepositoryMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 05/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
@testable import Grades

final class UserRepositoryMock: UserRepositoryProtocol {
	typealias Dependencies = HasNoDependency
	private let dependencies: Dependencies
	
	let user = BehaviorRelay<User?>(value:
		User(id: 14, username: "mockuser", firstName: "Ondřej", lastName: "Krátký"))
	
	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}
}
