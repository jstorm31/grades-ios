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

        // Style navigation bar
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.setBarTintColor(
            gradient: UIColor.Theme.primaryGradient,
            size: CGSize(width: UIScreen.main.bounds.size.width, height: 1)
        )

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.Grades.navigationBarTitle
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.Grades.navigationBarLargeTitle
        ]

        navigationItem.largeTitleDisplayMode = .always
        extendedLayoutIncludesOpaqueBars = true

        // Default toast style
        var toastStyle = ToastStyle()
        toastStyle.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        ToastManager.shared.style = toastStyle
    }

    open override var shouldAutorotate: Bool {
        return false
    }
}
