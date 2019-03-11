//
//  UINavigationBar+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 11/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

extension UINavigationBar {
    func setBarTintColor(gradient: CAGradientLayer, size: CGSize) {
        gradient.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        barTintColor = UIColor(patternImage: gradient.createGradientImage()!)
    }
}
