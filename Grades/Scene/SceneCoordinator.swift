//
//  SceneCoordinator.swift
//  Grades
//
//  Created by Jiří Zdvomka on 03/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class SceneCoordinator: SceneCoordinatorType {
    private var currentViewController: UIViewController!

    required init() {}

    func setRoot(viewController: UIViewController) {
        currentViewController = SceneCoordinator.actualViewController(for: viewController)
    }

    static func actualViewController(for viewController: UIViewController) -> UIViewController {
        if let navigationController = viewController as? UINavigationController {
            return navigationController.viewControllers.first!
        } else {
            return viewController
        }
    }

    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable {
        let subject = PublishSubject<Void>()
        let viewController = scene.viewController()

        switch type {
        case .push:
            guard let navigationController = currentViewController.navigationController else {
                fatalError("Can't push a view controller without a current navigation controller")
            }
            // one-off subscription to be notified when push complete
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            navigationController.pushViewController(viewController, animated: true)
            currentViewController = SceneCoordinator.actualViewController(for: viewController)

        case .modal:
            currentViewController.present(viewController, animated: true) {
                subject.onCompleted()
            }
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
        }
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }

    @discardableResult
    func pop(animated: Bool, presented: Bool = false) -> Completable {
        let subject = PublishSubject<Void>()

        if presented, let presenter = currentViewController.presentingViewController {
            // dismiss a modal controller
            currentViewController.dismiss(animated: animated) {
                self.currentViewController = SceneCoordinator.actualViewController(for: presenter)
                subject.onCompleted()
            }
        }

        if let navigationController = currentViewController.navigationController {
            // navigate up the stack
            // one-off subscription to be notified when pop complete
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            if navigationController.popViewController(animated: animated) == nil {
                Log.error("can't navigate back from \(String(describing: currentViewController))")
                return Observable.just(()).ignoreElements()
            }
            currentViewController = SceneCoordinator
                .actualViewController(for: navigationController.viewControllers.last!)
        } else {
            fatalError("Not a modal, no navigation controller: can't navigate back from \(String(describing: currentViewController))")
        }
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }

    @discardableResult
    func didPop() -> Completable {
        if let navigationController = currentViewController.navigationController {
            currentViewController = SceneCoordinator
                .actualViewController(for: navigationController.viewControllers.last!)
        }

        return Completable.empty()
    }
}
