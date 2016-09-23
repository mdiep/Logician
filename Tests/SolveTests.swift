//
//  SolveTests.swift
//  Logician
//
//  Created by Matt Diephouse on 9/6/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import XCTest
import Logician

class SolveTests: XCTestCase {
    func testSolve() {
        let xs = solve { (x: Variable<Int>) in
            let y = Variable<Int>()
            return any(
                x == 5,
                x == 6,
                x == y,
                x == 7
            )
        }
        XCTAssertEqual(xs.allValues(), [ 5, 6, 7 ])
    }
    
    func testSolveWithProperty() {
        let strings = solve { (x: Variable<String>) in
            return x.map { $0.characters.count } == 3
                && any(x == "cat", x == "dog", x == "bird", x == "mouse")
                && x != "cat"
        }
        XCTAssertEqual(strings.allValues(), [ "dog" ])
    }
    
    func testSolveWithInequality() {
        let xs: Generator<Int> = solve { x in
            let y = Variable<Int>()
            return any(x == 1, x == 2, x == 3)
                && y == 2
                && x != y
        }
        XCTAssertEqual(xs.allValues(), [ 1, 3 ])
    }
}
