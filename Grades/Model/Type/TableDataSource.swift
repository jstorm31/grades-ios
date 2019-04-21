//
//  TableDataSource.swift
//  Grades
//
//  Created by Jiří Zdvomka on 20/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxDataSources

/**
 Protocol for table data source configuration

 To configure TableView's data source, call provided configureDataSource() method.
 */
protocol TableDataSource {
    var dataSource: RxTableViewSectionedReloadDataSource<TableSection> { get set }
}

extension TableDataSource {
    static func configureDataSource() -> RxTableViewSectionedReloadDataSource<TableSection> {
        return RxTableViewSectionedReloadDataSource<TableSection>(
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: type(of: item).reuseId, for: indexPath)
                item.configure(cell: cell)
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                dataSource.sectionModels[index].header
            }
        )
    }
}
