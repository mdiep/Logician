//
//  StateTests.swift
//  Logician
//
//  Created by Matt Diephouse on 9/2/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import XCTest
@testable import Logician

func + (lhs: Variable<Int>, rhs: Int) -> Variable<Int> {
    return lhs.bimap(forward: { $0 + rhs }, backward: { $0 - rhs })
}

class StateTests: XCTestCase {
    // MARK: - `State.value(of: Property<Value>)`
    
    func testValueOfProperty() {
        var state = State()
        let x = Variable<String>()
        let y = x.map { $0.count }
        
        XCTAssertNil(state.value(of: y))
        
        try! state.unify(x, "foo")
        
        XCTAssertEqual(state.value(of: y), 3)
    }
    
    // MARK: - `State.value(of: Variable<Value>)`
    
    func testValueOfBimappedVariable() {
        var state = State()
        let x = Variable<Int>()
        let y = x + 2
        
        try! state.unify(x, 2)
        
        XCTAssertEqual(state.value(of: y), 4)
    }
    
    func testValueOfBimapped2Variable() {
        var state = State()
        let p1 = Variable<Point>()
        let p2 = Variable<Point>()
        let p3 = Variable<Point>()
        
        try! state.unify(p1, p2)
        try! state.unify(p1.x, 2)
        try! state.unify(p2.y, 4)
        XCTAssertEqual(state.value(of: p1), Point(2, 4))
        XCTAssertEqual(state.value(of: p2), Point(2, 4))
        
        try! state.unify(p3, Point(7, 9))
        XCTAssertEqual(state.value(of: p3.x), 7)
        XCTAssertEqual(state.value(of: p3.y), 9)
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
    
    func testUnifyBimappedVariableAndValue() {
        var state = State()
        let x = Variable<Int>()
        let y = x + 2
        
        try! state.unify(y, 4)
        try! state.unify(y, 4)
        
        XCTAssertEqual(state.value(of: x), 2)
        XCTAssertEqual(state.value(of: y), 4)
        XCTAssertThrowsError(try state.unify(x, 5))
        XCTAssertThrowsError(try state.unify(y, 5))
    }
    
    func testUnifyVariableAndVariableWithExistingValue() {
        var state = State()
        let x = Variable<Int>()
        let y = Variable<Int>()
        
        try! state.unify(x, 4)
        try! state.unify(x, y)
        
        XCTAssertEqual(state.value(of: y), 4)
    }
    
    func testUnifyBimappedVariableAndVariableWithExistingValue() {
        var state = State()
        let x = Variable<Int>()
        let y = Variable<Int>()
        let z = y + 2
        
        try! state.unify(x, 4)
        try! state.unify(x, z)
        
        XCTAssertEqual(state.value(of: x), 4)
        XCTAssertEqual(state.value(of: y), 2)
        XCTAssertEqual(state.value(of: z), 4)
    }
    
    func testUnifyVariableAndBimappedVariableWithExistingValue() {
        var state = State()
        let x = Variable<Int>()
        let y = Variable<Int>()
        let z = y + 2
        
        try! state.unify(y, 2)
        try! state.unify(x, z)
        
        XCTAssertEqual(state.value(of: x), 4)
        XCTAssertEqual(state.value(of: y), 2)
        XCTAssertEqual(state.value(of: z), 4)
    }
    
    func testUnifyVariableAndVariableWithNoExistingValue() {
        var state = State()
        let x = Variable<Int>()
        let y = Variable<Int>()
        
        try! state.unify(x, y)
        try! state.unify(x, 4)
        
        XCTAssertEqual(state.value(of: y), 4)
    }
    
    func testUnifyVariableAndBimappedVariableWithNoExistingValue() {
        var state = State()
        let x = Variable<Int>()
        let y = Variable<Int>()
        let z = y + 2
        
        try! state.unify(x, z)
        try! state.unify(x, 4)
        
        XCTAssertEqual(state.value(of: x), 4)
        XCTAssertEqual(state.value(of: y), 2)
        XCTAssertEqual(state.value(of: z), 4)
    }
    
    func testUnifyVariableAndVariableWithConflictingValues() {
        var state = State()
        let x = Variable<Int>()
        let y = Variable<Int>()
        
        try! state.unify(x, 4)
        try! state.unify(y, 5)
        
        XCTAssertThrowsError(try state.unify(x, y))
    }
    
    func testUnifyVariableAndBimappedVariableWithConflictingValues() {
        var state = State()
        let x = Variable<Int>()
        let y = Variable<Int>()
        let z = y + 2
        
        try! state.unify(z, 4)
        try! state.unify(x, 5)
        
        XCTAssertThrowsError(try state.unify(x, y))
    }
    
    func testUnifyBimappedVariablesWithConflictingValues() {
        var state = State()
        let x = Variable<Int>()
        let y = x + 3
        let z = x + 2
        
        try! state.unify(z, 4)
        
        XCTAssertThrowsError(try state.unify(y, 4))
    }
    
    func testUnifyBimapped2VariablesWithConflictingValues() {
        var state = State()
        let p = Variable<Point>()
        let q = Variable<Point>()
        let r = Variable<Point>()
        
        try! state.unify(p.x, 4)
        try! state.unify(q.x, 3)
        try! state.unify(r, Point(0, 0))
        
        XCTAssertThrowsError(try state.unify(p, q))
        XCTAssertThrowsError(try state.unify(p, r))
    }

    static var allTests: [(String, (StateTests) -> () throws -> Void)] {
        return [
            ("testValueOfProperty", testValueOfProperty),
            ("testValueOfBimappedVariable", testValueOfBimappedVariable),
            ("testValueOfBimapped2Variable", testValueOfBimapped2Variable),
            ("testConstrainBeforeUnifyingValue", testConstrainBeforeUnifyingValue),
            ("testConstrainAfterUnifyingValue", testConstrainAfterUnifyingValue),
            ("testConstrainAfterUnifyingConflictingValue", testConstrainAfterUnifyingConflictingValue),
            ("testConstrainBeforeUnifyingConflictingValue", testConstrainBeforeUnifyingConflictingValue),
            ("testConstrainBeforeUnifyingConflictingVariable", testConstrainBeforeUnifyingConflictingVariable),
            ("testUnifyVariableAndValue", testUnifyVariableAndValue),
            ("testUnifyBimappedVariableAndValue", testUnifyBimappedVariableAndValue),
            ("testUnifyVariableAndVariableWithExistingValue", testUnifyVariableAndVariableWithExistingValue),
            ("testUnifyBimappedVariableAndVariableWithExistingValue", testUnifyBimappedVariableAndVariableWithExistingValue),
            ("testUnifyVariableAndBimappedVariableWithExistingValue", testUnifyVariableAndBimappedVariableWithExistingValue),
            ("testUnifyVariableAndVariableWithNoExistingValue", testUnifyVariableAndVariableWithNoExistingValue),
            ("testUnifyVariableAndBimappedVariableWithNoExistingValue", testUnifyVariableAndBimappedVariableWithNoExistingValue),
            ("testUnifyVariableAndVariableWithConflictingValues", testUnifyVariableAndVariableWithConflictingValues),
            ("testUnifyVariableAndBimappedVariableWithConflictingValues", testUnifyVariableAndBimappedVariableWithConflictingValues),
            ("testUnifyBimappedVariablesWithConflictingValues", testUnifyBimappedVariablesWithConflictingValues),
            ("testUnifyBimapped2VariablesWithConflictingValues", testUnifyBimapped2VariablesWithConflictingValues),
        ]
    }
}

