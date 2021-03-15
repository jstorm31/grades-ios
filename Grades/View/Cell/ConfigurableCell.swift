//
//  ConfigurableCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 23/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

// From: https://medium.com/chili-labs/configuring-multiple-cells-with-generics-in-swift-dcd5e209ba16

protocol ConfigurableCell {
    associatedtype DataType
    func configure(data: DataType)
}

protocol CellConfigurator {
    static var reuseId: String { get }
    func configure(cell: UIView)
}

class TableCellConfigurator<CellType: ConfigurableCell, DataType>: CellConfigurator
    where CellType.DataType == DataType, CellType: UITableViewCell
{
    static var reuseId: String { return String(describing: CellType.self) }

    let item: DataType

    init(item: DataType) {
        self.item = item
    }

    func configure(cell: UIView) {
        // swiftlint:disable force_cast
        (cell as! CellType).configure(data: item)
    }
}
