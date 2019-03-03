//
//  SceneCoordinatorType.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import UIKit

protocol SceneCoordinatorType {
    /// transition to another scene
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable

    /// pop scene from navigation stack or dismiss current modal
    @discardableResult
    func pop(animated: Bool) -> Completable
}

extension SceneCoordinatorType {
    @discardableResult
    func pop() -> Completable {
        return pop(animated: true)
    }
}
