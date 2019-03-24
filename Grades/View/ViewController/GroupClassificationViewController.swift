//
//  GroupClassificationViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import UIKit

class GroupClassificationViewController: BaseTableViewController, BindableType {
    // MARK: properties

    var viewModel: GroupClassificationViewModelProtocol!

    // MARK: lifecycle

    override func loadView() {
        loadView(hasTableHeaderView: false)
        loadUI()
    }

    // MARK: methods

    func bindViewModel() {}

    // MARK: UI setup

    func loadUI() {}
}
