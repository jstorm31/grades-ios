//
//  CourseXMLParser.swift
//  Grades
//
//  Created by Jiří Zdvomka on 10/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation

class CourseXMLParser: NSObject {
    private var elementName: String = ""
    var courseName: String = ""
}

extension CourseXMLParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName: String?, attributes: [String: String] = [:]) {
        self.elementName = elementName
    }

    // 2
    func parser(_: XMLParser, didEndElement elementName: String, namespaceURI _: String?, qualifiedName _: String?) {}

    // 3
    func parser(_: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if !data.isEmpty, elementName == "atom:title" {
            courseName += data
        }
    }
}
