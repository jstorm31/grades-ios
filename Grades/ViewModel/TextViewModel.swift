//
//  TextViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 06/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxSwift
import UIKit

final class TextViewModel {
    typealias Dependencies = HasSceneCoordinator

    let type: TextScene
    let title: String
    let text: String
    private let dependencies: Dependencies

    lazy var onBackAction = CocoaAction { [weak self] in
        self?.dependencies.coordinator.didPop()
            .asObservable().map { _ in } ?? Observable.empty()
    }

    init(dependencies: Dependencies, type: TextScene) throws {
        self.type = type
        self.dependencies = dependencies

        switch type {
        case .credits:
            title = L10n.About.title
            text = L10n.About.text
        default:
            throw AppError.undefinedTextScene
        }
    }
}
