//
//  UITextField+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 18/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

// From: https://medium.com/swift2go/swift-add-keyboard-done-button-using-uitoolbar-c2bea50a12c7

import Action
import Foundation
import RxSwift
import UIKit

extension UITextField {
    func addCancelDoneButton(doneAction: CocoaAction) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        doneToolbar.barStyle = .default

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: L10n.Button.cancel, style: .plain, target: self, action: #selector(cancelButtonAction))
        var done = UIBarButtonItem(title: L10n.Button.done, style: .done, target: self, action: nil)
        done.rx.action = doneAction

        let items = [cancel, spacer, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        inputAccessoryView = doneToolbar
    }

    func addDoneButton(doneAction: CocoaAction) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        doneToolbar.barStyle = .default

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var done = UIBarButtonItem(title: L10n.Button.done, style: .done, target: self, action: nil)
        done.rx.action = doneAction

        let items = [spacer, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        inputAccessoryView = doneToolbar
    }

    @objc func cancelButtonAction() {
        resignFirstResponder()
    }

    func setBottomBorder(color _: UIColor, size: Float) {
        borderStyle = .none
        layer.backgroundColor = UIColor.white.cgColor

        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: Double(size))
        layer.shadowOpacity = size
        layer.shadowRadius = 0.0
    }
}
