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
    private let HEADER_HEIGHT = 80
    private var noContentLabel: UILabel!
    private let bag = DisposeBag()

    var tableView: UITableView!

    let showNoContent = BehaviorSubject<Bool>(value: true)

    func loadView(hasTableHeaderView: Bool = false) {
        super.loadView()

        let tableView = UITableView()
        view.addSubview(tableView)

        if hasTableHeaderView {
            let container = UIView()
            tableView.tableHeaderView = container
            container.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(20)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(HEADER_HEIGHT)
            }
        }

        tableView.snp.makeConstraints { make in
            if hasTableHeaderView {
                make.top.equalToSuperview().offset(HEADER_HEIGHT)
                make.leading.trailing.bottom.equalToSuperview()
            } else {
                make.edges.equalToSuperview()
            }
        }
        self.tableView = tableView

        let noContentLabel = UILabel()
        noContentLabel.text = L10n.Labels.noContent
        noContentLabel.font = UIFont.Grades.body
        noContentLabel.textColor = UIColor.Theme.grayText
        view.addSubview(noContentLabel)
        noContentLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.noContentLabel = noContentLabel
    }

    override func viewWillAppear(_: Bool) {
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        showNoContent.asDriver(onErrorJustReturn: false)
            .map { !$0 }
            .drive(noContentLabel.rx.isHidden)
            .disposed(by: bag)
    }

    func loadRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        tableView.refreshControl = refreshControl

        // Fix for table view refresh control
        edgesForExtendedLayout = .all
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.refreshControl!.sizeToFit()
        let top = tableView.adjustedContentInset.top
        let y = tableView.refreshControl!.frame.maxY + top + CGFloat(integerLiteral: HEADER_HEIGHT)
        tableView.setContentOffset(CGPoint(x: 0, y: -y), animated: true)
    }
}
