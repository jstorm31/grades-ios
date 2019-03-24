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
        super.loadView()
        loadView(hasTableHeaderView: false)

        navigationItem.title = viewModel.course.code

        loadUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeRightButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            viewModel.onBackAction.execute()
        }
    }

    // MARK: methods

    func bindViewModel() {}

    // MARK: UI setup

    func loadUI() {}
}
