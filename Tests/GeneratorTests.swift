//
//  GeneratorTests.swift
//  Logician
//
//  Created by Matt Diephouse on 9/4/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import XCTest
@testable import Logician

class GeneratorTests: XCTestCase {
    func testValues() {
        let iterator = Generator(values: [ 1, 1, 2, 3, 5 ])
        XCTAssertEqual(iterator.next(), 1)
        XCTAssertEqual(iterator.next(), 1)
        XCTAssertEqual(iterator.next(), 2)
        XCTAssertEqual(iterator.next(), 3)
        XCTAssertEqual(iterator.next(), 5)
        XCTAssertNil(iterator.next())
    }
    
    func testInterleaving() {
        let iterator = Generator(interleaving: [
            Generator(values: [  0,  1 ]),
            Generator(values: [ 10 ]),
            Generator(values: [ 20, 21, 22 ]),
        ])
        XCTAssertEqual(iterator.next(), 0)
        XCTAssertEqual(iterator.next(), 10)
        XCTAssertEqual(iterator.next(), 20)
        XCTAssertEqual(iterator.next(), 1)
        XCTAssertEqual(iterator.next(), 21)
        XCTAssertEqual(iterator.next(), 22)
        XCTAssertNil(iterator.next())
    }
    
    func testFlatMapOfOptionals() {
        let iterator = Generator(values: [ "a", "20", "c", "30" ])
            .flatMap { Int($0) }
        XCTAssertEqual(iterator.next(), 20)
        XCTAssertEqual(iterator.next(), 30)
        XCTAssertNil(iterator.next())
    }
    
    func testFlatMapOfGenerators() {
        let iterator = Generator(values: [ 10, 20, 30 ])
            .flatMap { Generator(values: [ $0 + 1, $0 + 2 ]) }
        XCTAssertEqual(iterator.next(), 11)
        XCTAssertEqual(iterator.next(), 12)
        XCTAssertEqual(iterator.next(), 21)
        XCTAssertEqual(iterator.next(), 22)
        XCTAssertEqual(iterator.next(), 31)
        XCTAssertEqual(iterator.next(), 32)
        XCTAssertNil(iterator.next())
    }
}
