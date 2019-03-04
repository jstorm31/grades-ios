//
//  LoginViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 01/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class LoginViewModel {
    // MARK: properties

    let sceneCoordinator: SceneCoordinatorType
    let authService: AuthenticationService
    private let bag = DisposeBag()

    // MARK: methods

    init(sceneCoordinator: SceneCoordinatorType, authenticationService: AuthenticationService) {
        self.sceneCoordinator = sceneCoordinator
        authService = authenticationService
    }

    func authenticate(viewController: UIViewController) -> Observable<Void> {
        let subscription = authService.authenticate(useBuiltInSafari: false, viewController: viewController).share()

        subscription
            .subscribe(onCompleted: { [weak self] in
                let subjectListViewModel = SubjectListViewModel()
                self?.sceneCoordinator.transition(to: .subjectList(subjectListViewModel), type: .modal)
            })
            .disposed(by: bag)

        return subscription
    }
}
