//
//  UIFont+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    enum Grades {
        static let primaryButton = UIFont(name: "Avenir-Roman", size: 24) ?? UIFont.systemFont(ofSize: 24)
        static let cellTitle = UIFont(name: "Avenir-Black", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        static let body = UIFont(name: "Avenir-Roman", size: 16) ?? UIFont.systemFont(ofSize: 16)
        static let boldBody = UIFont(name: "Avenir-Heavy", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        static let smallText = UIFont(name: "Avenir-Roman", size: 14) ?? UIFont.systemFont(ofSize: 14)
        static let navigationBarTitle = UIFont(name: "Avenir-Black", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        static let navigationBarLargeTitle = UIFont(name: "Avenir-Black", size: 30) ?? UIFont.boldSystemFont(ofSize: 30)
        static let display = UIFont(name: "Avenir-Black", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
        static let displaySmall = UIFont(name: "Avenir-Black", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        static let boldLarge = UIFont(name: "Avenir-Roman", size: 24) ?? UIFont.systemFont(ofSize: 24)
    }
}
