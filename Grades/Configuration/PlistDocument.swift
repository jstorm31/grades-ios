//
//  PlistDocument.swift
//  Grades
//
//  Created by Jiří Zdvomka on 01/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

private func arrayFromPlist<T>(at path: String) -> [T] {
    let bundle = Bundle(for: BundleToken.self)
    guard let url = bundle.url(forResource: path, withExtension: nil),
        let data = NSArray(contentsOf: url) as? [T] else {
        fatalError("Unable to load PLIST at path: \(path)")
    }
    return data
}

struct PlistDocument {
    let data: [String: Any]

    init(path: String) {
        let bundle = Bundle(for: BundleToken.self)
        guard let url = bundle.url(forResource: path, withExtension: nil),
            let data = NSDictionary(contentsOf: url) as? [String: Any] else {
            fatalError("Unable to load PLIST at path: \(path)")
        }
        self.data = data
    }

    subscript<T>(key: String) -> T {
        guard let result = data[key] as? T else {
            fatalError("Property '\(key)' is not of type \(T.self)")
        }
        return result
    }
}

private final class BundleToken {}
