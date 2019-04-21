//
//  User.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

class User: Codable {
    var userId: Int
    var username: String
    var firstName: String
    var lastName: String

    var name: String {
        return "\(firstName) \(lastName)"
    }

    var nameReverse: String {
        return "\(lastName) \(firstName)"
    }

    init(userId: Int, username: String, firstName: String, lastName: String) {
        self.userId = userId
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
    }

    init(fromUserInfo info: User) {
        userId = info.userId
        username = info.username
        firstName = info.firstName
        lastName = info.lastName
    }
}
