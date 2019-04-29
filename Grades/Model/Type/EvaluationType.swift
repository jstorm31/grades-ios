//
//  EvaluationType.swift
//  Grades
//
//  Created by Jiří Zdvomka on 29/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

enum EvaluationType: String, Codable {
    case manual = "MANUAL"
    case expression = "EXPRESSION"
    case aggregation = "AGGREGATION"
}
