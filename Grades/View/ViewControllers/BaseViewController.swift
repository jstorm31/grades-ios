//
//  BaseViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.Theme.background
    }
}
