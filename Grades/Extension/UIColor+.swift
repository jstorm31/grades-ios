//
//  UIColor+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    struct Theme {
        static let background = UIColor.white
        static let primary = UIColor(hex: 0x9776C1)
        static let secondary = UIColor(hex: 0x6763CE)
        static let secondaryDark = UIColor(hex: 0x8463CE)
        static let text = UIColor(hex: 0x525252)
        static let grayText = UIColor(hex: 0x8B8B8B)
        static let borderGray = UIColor(hex: 0xD8D8D8)
        static let textFieldWhiteOpaciy = UIColor(red: 255, green: 255, blue: 255, a: 0.2)
        static let lightGrayBackground = UIColor(hex: 0xFBFBFB)
        static let sectionGrayText = UIColor(hex: 0x7A7A7A)

        static let success = UIColor(hex: 0x73C0A2)
        static let danger = UIColor(hex: 0xCB544B)
        static let info = UIColor(hex: 0x7BAFC6)

        static let lightGreen = UIColor(hex: 0x45D75E)
        static let yellow = UIColor(hex: 0xFFCC00)
        static let orange = UIColor(hex: 0xFF9500)
        static let darkOrange = UIColor(hex: 0xBA6D00)

        static var primaryGradient: CAGradientLayer {
            let gradient: CAGradientLayer = CAGradientLayer()
            let startColor = UIColor(hex: 0x8C72C4).cgColor
            let endColor = UIColor(hex: 0x7468CA).cgColor

            gradient.colors = [startColor, endColor]
            gradient.startPoint = CGPoint(x: 0.0, y: 0.6)
            gradient.endPoint = CGPoint(x: 0.75, y: 0.0)

            return gradient
        }

        static func getGradeColor(forGrade grade: String, defaultColor: UIColor? = nil) -> UIColor {
            let color: UIColor

            switch grade {
            case "A":
                color = UIColor.Theme.lightGreen
            case "B":
                color = UIColor.Theme.success
            case "C":
                color = UIColor.Theme.yellow
            case "D":
                color = UIColor.Theme.orange
            case "E":
                color = UIColor.Theme.darkOrange
            case "F":
                color = UIColor.Theme.danger
            default:
                color = defaultColor ?? UIColor.Theme.text
            }

            return color
        }
    }

    /// Create UIColor from RGB
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }

    // Create UIColor from a hex value
    convenience init(hex: Int, a: CGFloat = 1.0) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            a: a
        )
    }
}
