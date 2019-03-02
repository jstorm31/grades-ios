//
//  UIPrimaryButton.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import UIKit

class UIPrimaryButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()

        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFontMetrics(forTextStyle: .body)
            .scaledFont(for: UIFont.Grades.primaryButton)
		titleLabel?.adjustsFontForContentSizeCategory = true

        clipsToBounds = true
        layer.cornerRadius = frame.size.height / 2
        apply(gradient: UIColor.Theme.primaryGradient)
    }
}
