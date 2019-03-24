//
//  StudentsClassification.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxDataSources

enum StudentsClassificationItem {
    case picker(title: String, value: String)
}

struct StudentsClassificationSection {
    var header: String
    var items: [StudentsClassificationItem]
}

extension StudentsClassificationSection: SectionModelType {
    typealias Item = StudentsClassificationItem

    init(original: StudentsClassificationSection, items: [Item]) {
        self = original
        self.items = items
    }
}
