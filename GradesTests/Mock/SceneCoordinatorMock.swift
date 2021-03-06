//
//  SceneCoordinatorMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 09/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import UIKit
@testable import Grades

final class SceneCoordinatorMock: SceneCoordinatorType {
	func setRoot(viewController: UIViewController) {}

	var targetScene: Scene?
	var popped = false
	
	func pop(animated: Bool) -> Completable {
		popped = true
		return Completable.empty()
	}
	
	func pop(animated: Bool, presented: Bool) -> Completable {
		popped = true
		return Completable.empty()
	}
    
    func popToRoot(animated: Bool) -> Completable {
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
