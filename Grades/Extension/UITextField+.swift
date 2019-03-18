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
    func addDoneButtonOnKeyboard(doneAction: CocoaAction) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: L10n.Button.cancel, style: .plain, target: self, action: #selector(cancelButtonAction))
        var done = UIBarButtonItem(title: L10n.Button.done, style: .done, target: self, action: nil)
        done.rx.action = doneAction

        let items = [flexSpace, cancel, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        inputAccessoryView = doneToolbar
    }

    @objc func cancelButtonAction() {
        resignFirstResponder()
    }
}
