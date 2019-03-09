//
//  Log.swift
//  Grades
//
//  Created by Jiří Zdvomka on 08/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Willow

// swiftlint:disable type_name
class Log {
    static let logger = Logger(logLevels: [.all], writers: [ConsoleWriter()])

    static func info(_ message: String) {
        logger.infoMessage("ℹ️ \(message)")
    }

    static func debug(_ message: String) {
        logger.debugMessage("🐛 \(message)")
    }

    static func error(_ message: String) {
        logger.errorMessage("⛔️ \(message)")
    }
}
