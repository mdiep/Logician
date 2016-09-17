//
//  ConstraintTests.swift
//  Logician
//
//  Created by Matt Diephouse on 9/17/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import XCTest
@testable import Logician

private func test(_ block: (inout State) throws -> ()) {
    var state = State()
    try! block(&state)
}

class ConstraintEqualTests: XCTestCase {
    func testSuccessWithValue() {
        let x = Variable<Int>()
        let y = Variable<Int>()
        let constraint = equal([x, y], value: 4)
        
        test {
            try! constraint.enforce($0)
        }
        
        test {
            try! $0.unify(x, 4)
            try! constraint.enforce($0)
        }
        
        test {
            try! $0.unify(y, 4)
            try! constraint.enforce($0)
        }
        
        test {
            try! $0.unify(x, 4)
            try! $0.unify(y, 4)
            try! constraint.enforce($0)
        }
    }
    
    func testFailureWithValue() {
        let x = Variable<Int>()
        let y = Variable<Int>()
        let constraint = equal([x, y], value: 4)
        
        test {
            try! $0.unify(x, 5)
            XCTAssertThrowsError(try constraint.enforce($0))
        }
        
        test {
            try! $0.unify(y, 5)
            XCTAssertThrowsError(try constraint.enforce($0))
        }
        
        test {
            let z = Variable<Int>()
            try! $0.unify(z, 5)
            try! $0.unify(x, z)
            XCTAssertThrowsError(try constraint.enforce($0))
        }
    }
    
    func testSuccessWithoutValue() {
        let x = Variable<Int>()
        let y = Variable<Int>()
        let constraint = equal([x, y])
        
        test {
            try! constraint.enforce($0)
        }
        
        test {
            try! $0.unify(x, 5)
            try! constraint.enforce($0)
        }
        
        test {
            try! $0.unify(y, 5)
            try! constraint.enforce($0)
        }
        
        test {
            try! $0.unify(x, 5)
            try! $0.unify(y, 5)
            try! constraint.enforce($0)
        }
        
        test {
            let z = Variable<Int>()
            try! $0.unify(x, z)
            try! $0.unify(y, z)
            try! constraint.enforce($0)
        }
        
        test {
            let z = Variable<Int>()
            try! $0.unify(x, z)
            try! $0.unify(y, z)
            try! $0.unify(z, 5)
            try! constraint.enforce($0)
        }
    }
    
    func testFailureWithoutValue() {
        let x = Variable<Int>()
        let y = Variable<Int>()
        let constraint = equal([x, y])
        
        test {
            try! $0.unify(x, 2)
            try! $0.unify(y, 7)
            XCTAssertThrowsError(try constraint.enforce($0))
        }
        
        test {
            let z = Variable<Int>()
            try! $0.unify(z, 2)
            try! $0.unify(x, z)
            try! $0.unify(y, 7)
            XCTAssertThrowsError(try constraint.enforce($0))
        }
    }
}
