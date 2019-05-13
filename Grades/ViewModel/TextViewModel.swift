//
//  TextViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 06/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxSwift

enum TextScene: Int {
    case about = 0
    case license = 1

    static func text(forIndex index: Int) -> TextScene {
        switch index {
        case 0:
            return .about
        case 1:
            return .license
        default:
            return .about
        }
    }
}

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

    init(dependencies: Dependencies, type: TextScene) {
        self.type = type
        self.dependencies = dependencies

        switch type {
        case .about:
            title = L10n.About.title
            text = L10n.About.text
        default:
            title = L10n.License.title
            text = L10n.License.text
        }
    }
}
