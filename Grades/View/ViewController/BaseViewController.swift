//
//  BaseViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//
import Toast
import UIKit

class BaseViewController: UIViewController {
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        #if DEBUG
            NSLog("ℹ️ Allocated ViewController: \(self)")
        #endif
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        #if DEBUG
            NSLog("ℹ️ Deallocated ViewController: \(self)")
        #endif
    }

    override func loadView() {
        super.loadView()

        view.backgroundColor = .white

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white

        // Style navigation bar for iOS 13
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.Grades.navigationBarTitle
            ]
            navBarAppearance.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.Grades.navigationBarLargeTitle
            ]
            navBarAppearance.backgroundColor = UIColor.Theme.primary
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        } else {
            // Style navigation bar
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
        }

        navigationItem.largeTitleDisplayMode = .always
        extendedLayoutIncludesOpaqueBars = true

        // Default toast style
        var toastStyle = ToastStyle()
        toastStyle.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        ToastManager.shared.style = toastStyle
    }

    override open var shouldAutorotate: Bool {
        return false
    }
}
