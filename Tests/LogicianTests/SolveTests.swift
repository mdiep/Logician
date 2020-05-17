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
            return x.map { $0.count } == 3
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
    
    func testSolveWithBimap() {
        let xs = solve { (x: Variable<Int>) in
            let plus1 = x.bimap(forward: { $0 + 1 }, backward: { $0 - 1 })
            return plus1 == 7 || plus1 == 12
        }
        XCTAssertEqual(xs.allValues(), [ 6, 11 ])
    }
    
    func testSolveWithBimap2() {
        let points = solve { (p: Variable<Point>) in
            let q = Variable<Point>()
            return any(
                p == q && p.x == 3 && q.y == 1,
                p.x == 4 && p == q && q.y == 2,
                p.x == 5 && q.y == 3 && p == q,
                p.x == 6 && p.y == 4 && q.x == 3 && p == q
            )
        }
        XCTAssertEqual(points.allValues(), [ Point(3, 1), Point(4, 2), Point(5, 3) ])
    }
    
    func testSolveWithNVariables() {
        let xs = solve { (variables: inout [Variable<Int>]) in
            let x = Variable<Int>()
            let y = Variable<Int>()
            variables = [x, y]
            return x == 4 && y == 3
        }
        let allValues = xs.allValues()
        XCTAssertEqual(allValues.count, 1)
        XCTAssertEqual(allValues[0], [4, 3])
    }

    static var allTests: [(String, (SolveTests) -> () throws -> Void)] {
        return [
            ("testSolve", testSolve),
            ("testSolveWithProperty", testSolveWithProperty),
            ("testSolveWithInequality", testSolveWithInequality),
            ("testSolveWithBimap", testSolveWithBimap),
            ("testSolveWithBimap2", testSolveWithBimap2),
            ("testSolveWithNVariables", testSolveWithNVariables),
        ]
    }
}
