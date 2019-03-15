//
//  BaseTableViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class BaseTableViewController: BaseViewController {
    var tableView: UITableView!

    func loadView(hasTableHeaderView: Bool = false) {
        super.loadView()

        let tableView = UITableView()
        view.addSubview(tableView)

        let headerHeight = 80
        if hasTableHeaderView {
            let container = UIView()
            tableView.tableHeaderView = container
            container.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(20)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(headerHeight)
            }
        }

        tableView.snp.makeConstraints { make in
            if hasTableHeaderView {
                make.top.equalToSuperview().offset(headerHeight)
                make.leading.trailing.bottom.equalToSuperview()
            } else {
                make.edges.equalToSuperview()
            }
        }
        self.tableView = tableView

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        tableView.refreshControl = refreshControl

        // Fix for table view refresh control
        edgesForExtendedLayout = .all
        self.tableView.contentInsetAdjustmentBehavior = .always
        tableView.refreshControl!.sizeToFit()
        let top = self.tableView.adjustedContentInset.top
        let y = tableView.refreshControl!.frame.maxY + top + CGFloat(integerLiteral: headerHeight)
        self.tableView.setContentOffset(CGPoint(x: 0, y: -y), animated: true)
    }

    override func viewWillAppear(_: Bool) {
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
    }
}
