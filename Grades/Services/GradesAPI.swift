//
//  GradesAPI.swift
//  Grades
//
//  Created by Jiří Zdvomka on 03/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Alamofire
import Foundation
import RxCocoa
import RxSwift

typealias JSONObject = [String: Any]

protocol GradesAPIProtocol {
    static func subjects() -> Observable<JSONObject>
}

class GradesAPI: GradesAPIProtocol {
    static let config = EnvironmentConfiguration.shared

    // MARK: - API errors

    enum Errors: Int, Error {
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
    }

    static func subjects() -> Observable<JSONObject> {
        return Observable.just([:])
    }
}
