//
//  UIPrimarySwitch.swift
//  Grades
//
//  Created by Jiří Zdvomka on 26/09/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

final class UIPrimarySwitch: UISwitch {
    override func layoutSubviews() {
        super.layoutSubviews()

        onTintColor = UIColor.Theme.primary
        tintColor = UIColor.Theme.primary
    }
}
