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
    let text: String
    let coordinator: SceneCoordinatorType

    lazy var onBackAction = CocoaAction { [weak self] in
        self?.coordinator.didPop()
            .asObservable().map { _ in } ?? Observable.empty()
    }

    init(type: TextScene, coordinator: SceneCoordinatorType) {
        self.type = type
        self.coordinator = coordinator
        text = "Even though using lorem ipsum often arouses curiosity due to its.\n resemblance to classical Latin, it is not intended to have meaning. Where text is visible in a document, people tend to focus on the textual content rather than upon overall presentation,\n\n so publishers use lorem ipsum when displaying a typeface or design in order to direct the focus to presentation. Lorem ipsum also approximates a typical distribution of letters in English."
    }
}
