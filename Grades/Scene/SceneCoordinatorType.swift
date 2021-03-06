//
//  SceneCoordinatorType.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import UIKit

protocol HasSceneCoordinator {
    var coordinator: SceneCoordinatorType { get }
}

protocol SceneCoordinatorType {
    func setRoot(viewController: UIViewController)

    /// transition to another scene
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable

    /// pop scene from navigation stack or dismiss current modal
    @discardableResult
    func pop(animated: Bool, presented: Bool) -> Completable

    @discardableResult
    func popToRoot(animated: Bool) -> Completable

    /// Sets scene's current ViewController after poped from scene
    @discardableResult
    func didPop() -> Completable
}

extension SceneCoordinatorType {
    @discardableResult
    func pop() -> Completable {
        return pop(animated: true, presented: false)
    }
}
