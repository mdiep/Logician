//
//  GoalTests.swift
//  Logician
//
//  Created by Matt Diephouse on 9/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import XCTest
@testable import Logician

let v = Variable<Int>()
let w = Variable<Int>()
let x = Variable<Int>()
let y = Variable<Int>()
let z = Variable<Int>()

let initial: State = {
    var state = State()
    try! state.unify(x, y)
    try! state.unify(z, 3)
    return state
}()

class GoalTests: XCTestCase {
    // MARK: - ==
    
    func testEqualityWithVariableAndValue() {
        let iterator = (x == 5)(initial)
        
        let state = iterator.next()!
        XCTAssertEqual(state.value(of: x), 5)
        XCTAssertEqual(state.value(of: y), 5)
        
        XCTAssertNil(iterator.next())
    }
    
    func testEqualityWithValueAndVariable() {
        let iterator = (5 == x)(initial)
        
        let state = iterator.next()!
        XCTAssertEqual(state.value(of: x), 5)
        XCTAssertEqual(state.value(of: y), 5)
        
        XCTAssertNil(iterator.next())
    }
    
    func testEqualityWithVariableAndVariable() {
        let iterator = (x == z)(initial)
        
        let state = iterator.next()!
        XCTAssertEqual(state.value(of: x), 3)
        XCTAssertEqual(state.value(of: y), 3)
        XCTAssertEqual(state.value(of: z), 3)
        
        XCTAssertNil(iterator.next())
    }
    
    // MARK: - in
    
    func testInWithVariable() {
        let iterator = x.in([2, 3, 4, 7])(initial)
        
        XCTAssertEqual(iterator.next()!.value(of: x), 2)
        XCTAssertEqual(iterator.next()!.value(of: x), 3)
        XCTAssertEqual(iterator.next()!.value(of: x), 4)
        XCTAssertEqual(iterator.next()!.value(of: x), 7)
        
        XCTAssertNil(iterator.next())
    }
    
    // MARK: - All
    
    func testAllSucceeds() {
        let iterator = all(v == 7, w == x, y == 8)(initial)
        
        let state = iterator.next()!
        XCTAssertEqual(state.value(of: v), 7)
        XCTAssertEqual(state.value(of: w), 8)
        XCTAssertEqual(state.value(of: x), 8)
        XCTAssertEqual(state.value(of: y), 8)
        XCTAssertEqual(state.value(of: z), 3)
        
        XCTAssertNil(iterator.next())
    }
    
    func testAllFails() {
        let iterator = all(w == z, w == 8)(initial)
        XCTAssertNil(iterator.next())
    }
    
    // MARK: - Any
    
    func testAny() {
        let goal = any(
            v == w && w == x && y == z,
            v == z && v == 9,
            v == 2 && w == 4 && x == 5
        )
        let iterator = goal(initial)
        
        let state1 = iterator.next()!
        XCTAssertEqual(state1.value(of: v), 3)
        XCTAssertEqual(state1.value(of: w), 3)
        XCTAssertEqual(state1.value(of: x), 3)
        XCTAssertEqual(state1.value(of: y), 3)
        XCTAssertEqual(state1.value(of: z), 3)
        
        let state2 = iterator.next()!
        XCTAssertEqual(state2.value(of: v), 2)
        XCTAssertEqual(state2.value(of: w), 4)
        XCTAssertEqual(state2.value(of: x), 5)
        XCTAssertEqual(state2.value(of: y), 5)
        XCTAssertEqual(state2.value(of: z), 3)
        
        XCTAssertNil(iterator.next())
    }
}
