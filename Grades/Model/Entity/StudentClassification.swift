//
//  StudentClassification.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

struct StudentClassification {
    var ident: String
    var firstName: String = ""
    var lastName: String = ""
    var username: String
    var value: DynamicValue?
}

extension StudentClassification {
    init(identifier: String, username: String, value: DynamicValue?) {
        ident = identifier
        self.username = username
        self.value = value
    }
}

extension StudentClassification: Codable {
    enum CodingKeys: String, CodingKey {
        case ident = "classificationIdentifier"
        case username = "studentUsername"
        case firstName, lastName, value
    }
}

extension StudentClassification: Comparable {
    static func == (lhs: StudentClassification, rhs: StudentClassification) -> Bool {
        return lhs.lastName == rhs.lastName && lhs.firstName == rhs.firstName && lhs.username == rhs.username
    }

    static func < (lhs: StudentClassification, rhs: StudentClassification) -> Bool {
        let lastName = lhs.lastName.localizedCompare(rhs.lastName)
        if lastName != .orderedSame {
            return lastName == .orderedAscending
        }

        let firstName = lhs.firstName.localizedCompare(rhs.firstName)
        if firstName != .orderedSame {
            return firstName == .orderedAscending
        }

        return lhs.username < rhs.username
    }
}
