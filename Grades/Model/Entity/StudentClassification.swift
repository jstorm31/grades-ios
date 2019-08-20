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
        return lhs.username == rhs.username
    }

	static func < (lhs: StudentClassification, rhs: StudentClassification) -> Bool {
		if lhs.lastName.localizedCompare(rhs.lastName).rawValue < 0 {
			return true
		}
		
		if lhs.firstName.localizedCompare(rhs.firstName).rawValue < 0 {
			return true
		}
		
		return lhs.username < rhs.username
	}
}
