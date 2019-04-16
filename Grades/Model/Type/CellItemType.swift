//
//  CellItemType.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

typealias PickerOption = (key: String, value: String)

/// Type for polymorphic table cells with associated values
enum CellItemType {
    case text(title: String, text: String)
    case picker(title: String, options: [PickerOption], valueIndex: Int)
    case textField(key: String, title: String)
}
