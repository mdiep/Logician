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
    // MARK: - `State.value(of: Property<Value>)`
    
    func testValueOfProperty() {
        var state = State()
        let x = Variable<String>()
        let y = x.map { $0.characters.count }
        
        XCTAssertNil(state.value(of: y))
        
        try! state.unify(x, "foo")
        
        XCTAssertEqual(state.value(of: y), 3)
    }
    
    // MARK: - `State.constrain()`
    
    func testConstrainBeforeUnifyingValue() {
        var state = State()
        let x = Variable<String>()
        
        try! state.unify(x, "foo")
        try! state.constrain(equal([x], value: "foo"))
    }
    
    func testConstrainAfterUnifyingValue() {
        var state = State()
        let x = Variable<String>()
        
        try! state.constrain(equal([x], value: "foo"))
        try! state.unify(x, "foo")
    }
    
    func testConstrainAfterUnifyingConflictingValue() {
        var state = State()
        let x = Variable<String>()
        try! state.unify(x, "foo")
        
        XCTAssertThrowsError(try state.constrain(equal([x], value: "bar")))
    }
    
    func testConstrainBeforeUnifyingConflictingValue() {
        var state = State()
        let x = Variable<String>()
        try! state.constrain(equal([x], value: "foo"))
        
        XCTAssertThrowsError(try state.unify(x, "bar"))
        XCTAssertNil(state.value(of: x))
    }
    
    func testConstrainBeforeUnifyingConflictingVariable() {
        var state = State()
        let x = Variable<String>()
        let y = Variable<String>()
        try! state.unify(y, "bar")
        try! state.constrain(equal([x], value: "foo"))
        
        XCTAssertThrowsError(try state.unify(x, y))
        
        XCTAssertNil(state.value(of: x))
        XCTAssertEqual(state.value(of: y), "bar")
    }
    
    // MARK: - `State.unify(Variable<Value>, Value)`
    
    func testUnifyVariableAndValue() {
        var state = State()
        let x = Variable<Int>()
        try! state.unify(x, 4)
        try! state.unify(x, 4)
        XCTAssertEqual(state.value(of: x), 4)
        XCTAssertThrowsError(try state.unify(x, 5))
    }
    
    func testUnifyVariableAndVariableWithExistingValue() {
        var state = State()
        let x = Variable<Int>()
        let y = Variable<Int>()
        try! state.unify(x, 4)
        try! state.unify(x, y)
        XCTAssertEqual(state.value(of: y), 4)
    }
    
    func testUnifyVariableAndVariableWithNoExistingValue() {
        var state = State()
        let x = Variable<Int>()
        let y = Variable<Int>()
        try! state.unify(x, y)
        try! state.unify(x, 4)
        XCTAssertEqual(state.value(of: y), 4)
    }
    
    func testUnifyVariableAndVariableWithConflictingValues() {
        var state = State()
        let x = Variable<Int>()
        let y = Variable<Int>()
        try! state.unify(x, 4)
        try! state.unify(y, 5)
        XCTAssertThrowsError(try state.unify(x, y))
    }
}
