//
//  UIView+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Toast
import UIKit

extension UIView {
    func apply(gradient: CAGradientLayer) {
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }

    enum ToastStyleType {
        case info
        case success
        case danger

        var style: ToastStyle {
            var style = ToastStyle()
            style.titleColor = .white
            style.cornerRadius = 4

            switch self {
            case .info:
                style.backgroundColor = UIColor.Theme.info
            case .success:
                style.backgroundColor = UIColor.Theme.success
            case .danger:
                style.backgroundColor = UIColor.Theme.danger
            }

            return style
        }
    }

    func makeCustomToast(type: ToastStyleType, message: String) {
        makeToast(message, style: type.style)
    }

    func makeCustomToast(_ message: String?, type: ToastStyleType, position: ToastPosition = ToastPosition.bottom) {
        makeToast(message, duration: 4.0, position: position, style: type.style)
    }
}
