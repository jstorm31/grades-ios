//
//  UIViewController+PickerPresentable.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import UIKit

protocol PickerPresentable where Self: UIViewController {
    var pickerView: UIPickerView! { get set }
    var pickerTextField: UITextField! { get set }
}

extension PickerPresentable {
    func setupPicker(doneAction: CocoaAction) {
        pickerTextField.addDoneButtonOnKeyboard(doneAction: doneAction)
    }

    func showPicker() {
        pickerTextField.becomeFirstResponder()
    }

    func hidePicker() {
        pickerTextField.resignFirstResponder()
    }
}
