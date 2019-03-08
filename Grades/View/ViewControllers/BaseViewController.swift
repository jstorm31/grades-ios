//
//  BaseViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import ToastSwiftFramework
import UIKit

class BaseViewController: UIViewController {
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.Theme.background

        // Default toast style
        var toastStyle = ToastStyle()
        toastStyle.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        ToastManager.shared.style = toastStyle
    }
}
