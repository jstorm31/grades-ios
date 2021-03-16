//
//  AuthenticationError.swift
//  Grades
//
//  Created by Jiří Zdvomka on 09/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

enum AuthenticationError: Error {
    case generic
    case invalidRefreshToken
}

extension AuthenticationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .generic:
            return L10n.Error.Auth.generic
        case .invalidRefreshToken:
            return L10n.Error.Auth.invalidRefreshToken
        }
    }
}
