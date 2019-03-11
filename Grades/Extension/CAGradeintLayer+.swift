//
//  CAGradeintLayer+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 11/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    func createGradientImage() -> UIImage? {
        UIGraphicsBeginImageContext(bounds.size)
        render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
