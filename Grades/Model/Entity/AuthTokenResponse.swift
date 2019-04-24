//
//  AuthTokenResponse.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

struct AuthTokenResponse {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Double
}

extension AuthTokenResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}
