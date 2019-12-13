//
//  TextScene.swift
//  Grades
//
//  Created by Jiří Zdvomka on 03/11/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

enum TextScene: Int {
    case termsAndConditions = 0
    case credits = 1
    case feedback = 2
    case rateApp = 3

    static func text(forIndex index: Int) throws -> TextScene {
        switch index {
        case 0:
            return .termsAndConditions
        case 1:
            return .credits
        case 2:
            return .feedback
        case 3:
            return .rateApp
        default:
            throw AppError.undefinedTextScene
        }
    }

    static func url(forScene scene: Self) throws -> URL? {
        switch scene {
        case .feedback:
            return URL(string: EnvironmentConfiguration.shared.feedbackLink)
        case .termsAndConditions:
            return URL(string: EnvironmentConfiguration.shared.termsAndConditionsLink)
        case .rateApp:
            return URL(string: EnvironmentConfiguration.shared.rateAppLink)
        default:
            throw AppError.undefinedUrlForScene
        }
    }
}
