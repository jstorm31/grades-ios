//
//  StudentClassificationViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

class StudentClassificationViewController: BaseTableViewController, BindableType {
    var viewModel: StudentClassificationViewModelProtocol!

    override func loadView() {
        loadView(hasTableHeaderView: false)
    }

    func bindViewModel() {}
}
