//
//  SceneCoordinatorMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 09/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
@testable import GradesDev

class SceneCoordinatorMock: SceneCoordinatorType {
	var targetScene: Scene?
	var popped = false
	
	func pop(animated: Bool) -> Completable {
		popped = true
		return Completable.empty()
	}
	
	func didPop() -> Completable {
		popped = true
		return Completable.empty()
	}
	
	func transition(to scene: Scene, type: SceneTransitionType) -> Completable {
		targetScene = scene
		return Completable.empty()
	}
}
