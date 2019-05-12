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
    let type: TextScene
    let title: String
    let text: String
    let coordinator: SceneCoordinatorType

    lazy var onBackAction = CocoaAction { [weak self] in
        self?.coordinator.didPop()
            .asObservable().map { _ in } ?? Observable.empty()
    }

    init(type: TextScene, coordinator: SceneCoordinatorType) {
        self.type = type
        self.coordinator = coordinator

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
