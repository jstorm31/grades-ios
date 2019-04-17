//
//  CellItemType.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

/// Type for polymorphic table cells with associated values
enum CellItemType {
    case text(title: String, text: String)
    case picker(title: String, options: [String], valueIndex: Int)
    case dynamicValue(viewModel: DynamicValueCellViewModel)
}
