//
//  DynamicValue.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

enum DynamicValueType: String, Codable {
    case number = "NUMBER"
    case string = "STRING"
    case bool = "BOOLEAN"
}

/// Type for handling type-polymorfic external data
/// E.G. JSON from external source
enum DynamicValue: Codable {
    case number(Double?)
    case string(String?)
    case bool(Bool?)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            self = try .number(container.decode(Double.self))
        } catch DecodingError.typeMismatch {
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                do {
                    self = try .bool(container.decode(Bool.self))
                } catch {
                    self = .number(nil)
                }
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .number(number):
            try container.encode(number)
        case let .string(string):
            try container.encode(string)
        case let .bool(bool):
            try container.encode(bool)
        }
    }
}

extension DynamicValue: Equatable {
    static func == (lhs: DynamicValue, rhs: DynamicValue) -> Bool {
        if case let .string(lhsVal) = lhs, case let .string(rhsVal) = rhs {
            return lhsVal == rhsVal
        }

        if case let .number(lhsVal) = lhs, case let .number(rhsVal) = rhs {
            return lhsVal == rhsVal
        }

        if case let .bool(lhsVal) = lhs, case let .bool(rhsVal) = rhs {
            return lhsVal == rhsVal
        }

        return false
    }
}
