//
//  StudentClassificationTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 25/09/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
@testable import Grades

class StudentClassificationTests: XCTestCase {
    func testLessThan() {
        let a = StudentClassification(ident: "a", firstName: "Ivan", lastName: "Bříza", username: "briziv4", value: nil)
        let b = StudentClassification(ident: "b", firstName: "Roman", lastName: "Kožený", username: "kozenrom1", value: nil)
        
        XCTAssertLessThan(a, b)
        XCTAssertFalse(a < a)
        XCTAssertTrue(!(a < b) || !(b < a))
    }
    
    func testLessThanLocalized() {
        let a = StudentClassification(ident: "a", firstName: "Ivan", lastName: "Bríza", username: "briziv4", value: nil)
        let b = StudentClassification(ident: "b", firstName: "Roman", lastName: "Bříza", username: "kozenrom1", value: nil)
        
        XCTAssertLessThan(a, b)
    }
    
    func testLessThanFirstName() {
        let a = StudentClassification(ident: "a", firstName: "Ivan", lastName: "Bříza", username: "briziv4", value: nil)
        let b = StudentClassification(ident: "b", firstName: "Roman", lastName: "Bříza", username: "kozenrom1", value: nil)
        
        XCTAssertLessThan(a, b)
    }
    
    func testLessThanUsername() {
        let a = StudentClassification(ident: "a", firstName: "Ivan", lastName: "Bříza", username: "briziv3", value: nil)
        let b = StudentClassification(ident: "b", firstName: "Ivan", lastName: "Bříza", username: "briziv4", value: nil)
        
        XCTAssertNotEqual(a, b)
        XCTAssertLessThan(a, b)
    }
    
    func testSortArray() {
        let items = [
            StudentClassification(ident: "a", firstName: "Jana", lastName: "Kučera", username: "krehjana", value: DynamicValue.number(18.0 as Double?)),
            StudentClassification(ident: "b", firstName: "Ivan", lastName: "Janata", username: "dlouhiv4", value: DynamicValue.number(34.0 as Double?)),
            StudentClassification(ident: "c", firstName: "Ondřej", lastName: "Tomek", username: "kvitond", value: DynamicValue.number(41.0 as Double?)),
            StudentClassification(ident: "a", firstName: "Jana", lastName: "Podroužek", username: "krehjana", value: DynamicValue.number(18.0 as Double?)),
            StudentClassification(ident: "b", firstName: "Ivan", lastName: "Otta", username: "dlouhiv4", value: DynamicValue.number(34.0 as Double?)),
            StudentClassification(ident: "c", firstName: "Ondřej", lastName: "Rousek", username: "kvitond", value: DynamicValue.number(41.0 as Double?)),
            StudentClassification(ident: "d", firstName: "Zdeněk", lastName: "Zelenková", username: "zhorzden", value: DynamicValue.number(10.0 as Double?)),
            StudentClassification(ident: "b", firstName: "Ivan", lastName: "Sajdl", username: "dlouhiv4", value: DynamicValue.number(34.0 as Double?)),
            StudentClassification(ident: "c", firstName: "Ondřej", lastName: "Kunz", username: "kvitond", value: DynamicValue.number(41.0 as Double?)),
            StudentClassification(ident: "d", firstName: "Zdeněk", lastName: "Vele", username: "zhorzden", value: DynamicValue.number(10.0 as Double?)),
            StudentClassification(ident: "b", firstName: "Ivan", lastName: "Stoklasová", username: "dlouhiv4", value: DynamicValue.number(34.0 as Double?)),
            StudentClassification(ident: "c", firstName: "Ondřej", lastName: "Svoboda", username: "kvitond", value: DynamicValue.number(41.0 as Double?)),
            StudentClassification(ident: "d", firstName: "Zdeněk", lastName: "Vahanyan", username: "zhorzden", value: DynamicValue.number(10.0 as Double?)),
        ]
        
        let sorted = items.sorted().map { $0.lastName }
        
        XCTAssertEqual(sorted, ["Janata", "Kučera", "Kunz", "Otta", "Podroužek", "Rousek", "Sajdl", "Stoklasová", "Svoboda", "Tomek", "Vahanyan", "Vele", "Zelenková"])
    }
}
