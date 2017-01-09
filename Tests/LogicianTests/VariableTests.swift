//
//  VariableTests.swift
//  Logician
//
//  Created by Matt Diephouse on 9/2/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import XCTest
@testable import Logician

class VariableTests: XCTestCase {
    func testIdentity() {
        let var1 = Variable<Int>()
        let var2 = var1
        let var3 = Variable<Int>()
        XCTAssertTrue(var1 == var2)
        XCTAssertFalse(var1 == var3)
        XCTAssertFalse(var2 == var3)
    }

    static var allTests: [(String, (VariableTests) -> () throws -> Void)] {
        return [
            ("testIdentity", testIdentity),
        ]
    }
}
