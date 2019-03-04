//
//  User.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

class UserInfo: Codable {
    var userId: Int
    var username: String
    var firstName: String
    var lastName: String

    var name: String {
        return "\(firstName) \(lastName)"
    }

    init(fromUserInfo info: UserInfo) {
        userId = info.userId
        username = info.username
        firstName = info.firstName
        lastName = info.lastName
    }
}

struct UserRoles: Codable {
    var studentCourses: [String]
    var teacherCourses: [String]
}

class User: UserInfo {
    var roles: UserRoles

    init(info: UserInfo, roles: UserRoles) {
        self.roles = roles
        super.init(fromUserInfo: info)
    }

    required init(from _: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
