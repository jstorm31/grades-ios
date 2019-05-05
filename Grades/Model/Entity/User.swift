//
//  User.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

struct User {
    var id: Int
    var username: String
    var firstName: String
    var lastName: String
    var roles = [Role]()

    var name: String {
        return "\(firstName) \(lastName)"
    }

    var nameReverse: String {
        return "\(lastName) \(firstName)"
    }

    var toString: String {
        return "\(name) (\(username))"
    }

    enum Role {
        case student, teacher

        func toString() -> String {
            switch self {
            case .student:
                return L10n.UserRoles.student
            case .teacher:
                return L10n.UserRoles.teacher
            }
        }
    }

    init(id: Int, username: String, firstName: String, lastName: String) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
    }

    init(fromUser user: User) {
        id = user.id
        username = user.username
        firstName = user.firstName
        lastName = user.lastName
    }

    func contains(_ text: String) -> Bool {
        return username.lowercased().contains(text)
            || firstName.lowercased().contains(text)
            || lastName.lowercased().contains(text)
            || name.lowercased().contains(text)
            || nameReverse.lowercased().contains(text)
    }
}

extension User: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case username, firstName, lastName
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.username == rhs.username
    }
}
