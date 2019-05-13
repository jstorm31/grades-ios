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
    var items: [CellConfigurator]
}

extension TableSection: SectionModelType {
    typealias Item = CellConfigurator

    init(original: TableSection, items: [Item]) {
        self = original
        self.items = items
    }
}
