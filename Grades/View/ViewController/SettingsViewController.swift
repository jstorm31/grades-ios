//
//  SettingsViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 18/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class SettingsViewController: BaseTableViewController, BindableType {
    var viewModel: SettingsViewModel!

    override func loadView() {
        super.loadView()
        loadView(hasTableHeaderView: false)

        navigationItem.title = L10n.Settings.title
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeRightButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            viewModel.onBack.execute()
        }
    }

    func bindViewModel() {}
}
