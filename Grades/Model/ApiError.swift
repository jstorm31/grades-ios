//
//  ApiError.swift
//  Grades
//
//  Created by Jiří Zdvomka on 08/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

enum ApiError: Int, Error {
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case general = 0
    case unprocessableData = 1
    case undecodableData = 2
    case undefinedUser = 3

    static func getError(forCode code: Int) -> ApiError {
        switch code {
        case unauthorized.rawValue:
            return unauthorized
        case forbidden.rawValue:
            return forbidden
        case notFound.rawValue:
            return notFound
        default:
            return general
        }
    }
}

extension ApiError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString(L10n.Error.Api.generic, comment: "")
    }

    public var failureReason: String? {
        return NSLocalizedString("Error code: \(rawValue)", comment: "")
    }
}
