//
//  StudentClassificationViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

final class StudentClassificationViewModel {
	typealias Dependencies = HasTeacherRepository
	
	private let dependencies: Dependencies
	private let coordinator: SceneCoordinatorType
	
	init(dependencies: AppDependency, coordinator: SceneCoordinatorType) {
		self.dependencies = dependencies
		self.coordinator = coordinator
	}
	
	
}
