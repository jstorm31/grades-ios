//
//  StudentSearchViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 21/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

final class StudentSearchViewController: BaseTableViewController, BindableType {
    var viewModel: StudentSearchViewModel!

    // MARK: Lifecycle

    override func loadView() {
        super.loadView()
        navigationItem.title = L10n.Students.title
        loadUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            viewModel.onBackAction.execute()
        }
    }

    // MARK: binding

    func bindViewModel() {}

    // MARK: UI setup

    private func loadUI() {}
}
