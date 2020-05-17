//
//  PropertyTests.swift
//  Logician
//
//  Created by Matt Diephouse on 9/14/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import XCTest
@testable import Logician

class PropertyTests: XCTestCase {
    func testIdentity() {
        let length1 = Variable<String>().map { $0.count }
        let length2 = length1
        let length3 = Variable<String>().map { $0.count }
        XCTAssertTrue(length1 == length2)
        XCTAssertFalse(length1 == length3)
        XCTAssertFalse(length2 == length3)
    }
    
    func testTypeErasure() {
        let property = Variable<String>().map { $0.count }
        XCTAssertTrue(property.erased == property)
        XCTAssertEqual(property.erased, property.erased)
    }

    static var allTests: [(String, (PropertyTests) -> () throws -> Void)] {
        return [
            ("testIdentity", testIdentity),
            ("testTypeErasure", testTypeErasure),
        ]
    }
}
