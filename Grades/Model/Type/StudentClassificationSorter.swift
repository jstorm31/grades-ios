//
//  StudentEvaluationFilter.swift
//  Grades
//
//  Created by Jiří Zdvomka on 20/08/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

protocol StudentClassificationSorter {
    var title: String { get }

    func sort(_ classifications: [StudentClassification], ascending: Bool) -> [StudentClassification]
}

final class StudentClassificationNameSorter: StudentClassificationSorter {
    var title = L10n.Sorter.name

    /// Sorts items by name
    func sort(_ classifications: [StudentClassification], ascending: Bool = true) -> [StudentClassification] {
        return ascending ? classifications.sorted() : classifications.sorted().reversed()
    }
}

final class StudentClassificationValueSorter: StudentClassificationSorter {
    var title = L10n.Sorter.value

    /// Sorts items by value
    func sort(_ classifications: [StudentClassification], ascending: Bool = true) -> [StudentClassification] {
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
