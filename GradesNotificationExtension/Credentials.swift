//
//  Credentials.swift
//  GradesNotificationExtension
//
//  Created by Jiří Zdvomka on 12/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

struct Credentials {
	var refreshToken: String
	var accessToken: String
	var username: String?
	var expiresAt: Date?
}
