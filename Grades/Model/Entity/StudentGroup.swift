//
//  StudentGroup.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

struct StudentGroup {
    let id: String
    let name: String?
}

extension StudentGroup: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "studentGroupId"
        case name
    }
}
