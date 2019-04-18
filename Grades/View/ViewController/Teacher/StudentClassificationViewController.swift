//
//  StudentClassificationViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

final class StudentClassificationViewController: BaseTableViewController, BindableType {
    var viewModel: StudentClassificationViewModel!

    override func loadView() {
        loadView(hasTableHeaderView: false)
        loadUI()
    }

    override func viewDidLoad() {
        viewModel.bindOutput()
    }

    func bindViewModel() {}

    func loadUI() {
        loadRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
    }

    // MARK: events

    @objc private func refreshControlPulled(_: UIRefreshControl) {
        // TODO:
    }
}
