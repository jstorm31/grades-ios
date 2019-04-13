//
//  TableSection.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxDataSources

struct TableSection {
    var header: String
    var items: [CellItemType]
}

extension TableSection: SectionModelType {
    typealias Item = CellItemType

    init(original: TableSection, items: [Item]) {
        self = original
        self.items = items
    }
}
