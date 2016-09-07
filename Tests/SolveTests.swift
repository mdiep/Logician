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
        let xs: AnyIterator<Int> = solve { x in
            return any(
                x == 5,
                x == 6,
                x == 7
            )
        }
        XCTAssertEqual(xs.map { $0 }, [ 5, 6, 7 ])
    }
}
