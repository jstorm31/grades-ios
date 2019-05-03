//
//  NotificationRegistration.swift
//  Grades
//
//  Created by Jiří Zdvomka on 27/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

struct NotificationRegistration {
    var token: String
    var type: String?
}

extension NotificationRegistration: Encodable {}
