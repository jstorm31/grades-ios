//
//  Optional+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 25/09/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

extension Optional where Wrapped == DynamicValue {
    static func < (lhs: DynamicValue?, rhs: DynamicValue?) -> Bool {
        if lhs == nil, rhs != nil { return true }
        if lhs != nil, rhs == nil { return false }

        return lhs! < rhs!
    }

    static func > (lhs: DynamicValue?, rhs: DynamicValue?) -> Bool {
        if lhs == nil, rhs != nil { return false }
        if lhs != nil, rhs == nil { return true }

        return lhs! > rhs!
    }
}

extension Optional where Wrapped == String {
    static func < (lhs: String?, rhs: String?) -> Bool {
        if lhs == nil, rhs != nil { return true }
        if lhs != nil, rhs == nil { return false }

        return lhs! < rhs!
    }
}

extension Optional where Wrapped == Double {
    static func < (lhs: Double?, rhs: Double?) -> Bool {
        if lhs == nil, rhs != nil { return true }
        if lhs != nil, rhs == nil { return false }

        return lhs! < rhs!
    }
}

extension Optional where Wrapped == Bool {
    static func < (lhs: Bool?, rhs: Bool?) -> Bool {
        if lhs == nil, rhs != nil { return true }
        if lhs != nil, rhs == nil { return false }

        return lhs! || (!lhs! && !rhs!)
    }
}
