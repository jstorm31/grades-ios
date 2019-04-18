//
//  SceneTransitionTyep.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

enum SceneTransitionType {
    case root // make view controller the root view controller
    case push // push view controller to navigation stack
    case modal // present view controller modally
}
