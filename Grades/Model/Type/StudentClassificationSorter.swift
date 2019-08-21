//
//  StudentEvaluationFilter.swift
//  Grades
//
//  Created by Jiří Zdvomka on 20/08/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

protocol StudentClassificationSorter {
    func sort(classifications: [StudentClassification]) -> [StudentClassification]
}

final class StudentClassificationNameSorter: StudentClassificationSorter {
    /// Sorts items by name
    func sort(classifications: [StudentClassification]) -> [StudentClassification] {
        return classifications.sorted()
    }
}

final class StudentClassificationValueSorter: StudentClassificationSorter {
    /// Sorts items by value
    func sort(classifications: [StudentClassification]) -> [StudentClassification] {
        return classifications.sorted(by: { lhs, rhs in
            guard let lhsValue = lhs.value, let rhsValue = rhs.value else {
                return false
            }

            if lhsValue == rhsValue {
                return lhs < rhs // sort by default order
            }
            return lhsValue < rhsValue
        })
    }
}
