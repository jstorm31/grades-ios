//
//  TextScene.swift
//  Grades
//
//  Created by Jiří Zdvomka on 03/11/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import StoreKit

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
        default:
            throw TextSceneError.undefinedUrlForScene
        }
    }

    /// Opens review action for the app in AppStore
    func rateApp() throws {
        if case .rateApp = self {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                guard let appId = Bundle.main.bundleIdentifier else { return }
                let urlStr = EnvironmentConfiguration.shared.rateAppLink.replacingOccurrences(of: ":appId", with: appId)

                guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.open(url, options: [:])
            }
        } else {
            throw TextSceneError.notRateAppCase
        }
    }
}

enum TextSceneError: Error {
    case undefinedUrlForScene
    case notRateAppCase
}
