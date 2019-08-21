//
//  StudentEvaluationFilter.swift
//  Grades
//
//  Created by Jiří Zdvomka on 20/08/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

protocol StudentClassificationSorter {
    func sort(classifications: [StudentClassification], ascending: Bool) -> [StudentClassification]
}

final class StudentClassificationNameSorter: StudentClassificationSorter {
    /// Sorts items by name
    func sort(classifications: [StudentClassification], ascending: Bool = true) -> [StudentClassification] {
        return ascending ? classifications.sorted() : classifications.sorted().reversed()
    }
}

final class StudentClassificationValueSorter: StudentClassificationSorter {
    /// Sorts items by value
    func sort(classifications: [StudentClassification], ascending: Bool = true) -> [StudentClassification] {
        return classifications.sorted(by: { lhs, rhs in
            guard let lhsValue = lhs.value, let rhsValue = rhs.value else {
                return false
            }

            if lhsValue == rhsValue {
                return ascending ? lhs < rhs : lhs > rhs // sort by default order
            }
            return ascending ? lhsValue < rhsValue : lhsValue > rhsValue
        })
    }
}
