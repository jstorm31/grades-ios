//
//  EnvironmentConfiguration.swift
//  Classification
//
//  Created by Jiří Zdvomka on 25/02/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

// taken from https://benscheirman.com/2018/10/xcode-environment-specific-configuration/

import Foundation

final class EnvironmentConfiguration {
    private let config: NSDictionary

    static let shared = EnvironmentConfiguration()

    private init(dictionary: NSDictionary) {
        config = dictionary
    }

    private convenience init() {
        let dict = NSMutableDictionary()

        let commonConfiguration = PlistDocument(path: "Common.plist").data
        dict.addEntries(from: commonConfiguration)

        if let environment = Bundle.main.infoDictionary!["ConfigEnvironment"] as? String {
            let path = "\(environment).plist"
            let environmentConfiguration = PlistDocument(path: path).data
            dict.addEntries(from: environmentConfiguration)
        }

        self.init(dictionary: dict)
    }
}

struct Auth {
    var authorizeUrl: String = ""
    var tokenUrl: String = ""
    var clientId: String = ""
    var clientSecret: String = ""
    var clientHash: String = ""
    var callbackId: String = ""
    var responseType: String = ""
    var scope: String = ""

    var redirectUri: String {
        return "\(Bundle.main.bundleIdentifier!)://\(callbackId)"
    }
}

protocol NSClassificationConfiguration {
    var defaultLanguage: String { get }
    var auth: Auth { get }
    var gradesAPI: [String: String] { get }
    var notificationServerUrl: String { get }
    var keychain: KeychainCredentials { get }
}

// swiftlint:disable force_cast
// Note: for debugging it is better for the app to crash if corresponding key
//       is missing rather than providing default value
extension EnvironmentConfiguration: NSClassificationConfiguration {
    var defaultLanguage: String {
        return config["DefaultLanguage"] as! String
    }

    var auth: Auth {
        return Auth(authorizeUrl: config["AuthorizeUrl"] as! String,
                    tokenUrl: config["TokenUrl"] as! String,
                    clientId: config["ClientId"] as! String,
                    clientSecret: config["ClientSecret"] as! String,
                    clientHash: config["ClientHash"] as! String,
                    callbackId: config["CallbackKey"] as! String,
                    responseType: config["AuthResponseType"] as! String,
                    scope: config["AuthScope"] as! String)
    }

    var gradesAPI: [String: String] {
        var dict = config["GradesAPIEndpoints"] as! [String: String]
        dict["BaseURL"] = config["GradesApiUrl"] as? String

        return dict
    }

    var notificationServerUrl: String {
        return config["NotificationServerUrl"] as! String
    }

    var keychain: KeychainCredentials {
        return KeychainCredentials(serviceName: config["KeychainServiceName"] as! String,
                                   accessGroup: config["KeychainAccessGroup"] as! String)
    }

    var sentryUrl: String {
        return config["SentryUrl"] as! String
    }

    var feedbackLink: String {
        return config["FeedbackLink"] as! String
    }

    var termsAndConditionsLink: String {
        return config["TermsAndConditionsLink"] as! String
    }

    var rateAppLink: String {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            return (config["RateAppLink"] as! String) + bundleIdentifier
        }
        return config["RateAppLink"] as! String
    }
}

struct KeychainCredentials {
    let serviceName: String
    let accessGroup: String
}
