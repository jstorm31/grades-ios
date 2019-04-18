//
//  UISecondaryButton.swift
//  Grades
//
//  Created by Jiří Zdvomka on 18/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

class UISecondaryButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.font = UIFontMetrics(forTextStyle: .body)
            .scaledFont(for: UIFont.Grades.smallText)
        setTitleColor(UIColor.Theme.secondary, for: .normal)
        setTitleColor(UIColor.Theme.secondaryDark, for: .selected)
    }
}
