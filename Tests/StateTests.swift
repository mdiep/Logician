//
//  StateTests.swift
//  Logician
//
//  Created by Matt Diephouse on 9/2/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import XCTest
@testable import Logician

class StateTests: XCTestCase {
    func testUnifyVariableAndValue() {
        var context = State()
        let x = Variable<Int>()
        try! context.unify(x, 4)
        try! context.unify(x, 4)
        XCTAssertEqual(context.value(of: x), 4)
        XCTAssertThrowsError(try context.unify(x, 5))
    }
    
    func testUnifyVariableAndVariableWithExistingValue() {
        var context = State()
        let x = Variable<Int>()
        let y = Variable<Int>()
        try! context.unify(x, 4)
        try! context.unify(x, y)
        XCTAssertEqual(context.value(of: y), 4)
    }
    
    func testUnifyVariableAndVariableWithNoExistingValue() {
        var context = State()
        let x = Variable<Int>()
        let y = Variable<Int>()
        try! context.unify(x, y)
        try! context.unify(x, 4)
        XCTAssertEqual(context.value(of: y), 4)
    }
    
    func testUnifyVariableAndVariableWithConflictingValues() {
        var context = State()
        let x = Variable<Int>()
        let y = Variable<Int>()
        try! context.unify(x, 4)
        try! context.unify(y, 5)
        XCTAssertThrowsError(try context.unify(x, y))
    }
}
