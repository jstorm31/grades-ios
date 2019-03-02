//
//  UIView+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func apply(gradient: CAGradientLayer) {
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }
}
