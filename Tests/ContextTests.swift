//
//  ContextTests.swift
//  Logician
//
//  Created by Matt Diephouse on 9/1/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import XCTest
@testable import Logician

private let key1 = "a"
private let key2 = "b"
private let key3 = "c"

class ContextTests: XCTestCase {
    func testUpdateValueForKey() {
        var context = Context<String, Int>()
        
        XCTAssertNil(context[key1])
        
        context.updateValue(8, forKey: key1)
        XCTAssertEqual(context[key1], 8)
        
        context.updateValue(nil, forKey: key1)
        XCTAssertNil(context[key1])
        
        context[key1] = 7
        XCTAssertEqual(context[key1], 7)
        
        context[key1] = nil
        XCTAssertNil(context[key1])
    }
    
    func testRemoveValueForKey() {
        var context = Context<String, Int>()
        context.updateValue(8, forKey: key1)
        
        XCTAssertEqual(context[key1], 8)
        context.removeValue(forKey: key1)
        XCTAssertNil(context[key1])
    }
    
    func testUpdateValueForKeyTransform() {
        var context = Context<String, Int>()
        
        context.updateValue(forKey: key1) { value in
            XCTAssertNil(value)
            return 7
        }
        XCTAssertEqual(context[key1], 7)
        
        context.updateValue(forKey: key1) { value in
            XCTAssertEqual(value, 7)
            return 3
        }
        XCTAssertEqual(context[key1], 3)
    }
    
    func testMerge() {
        var context = Context<String, Int>()
        
        context.merge(key1, key2) { _, _ in 3 }
        XCTAssertEqual(context[key1], 3)
        XCTAssertEqual(context[key2], 3)
        
        context[key1] = 4
        XCTAssertEqual(context[key1], 4)
        XCTAssertEqual(context[key2], 4)
        
        context.merge(key2, key3) { _, _ in nil }
        XCTAssertNil(context[key1])
        XCTAssertNil(context[key2])
        XCTAssertNil(context[key3])
        
        context[key1] = 6
        XCTAssertEqual(context[key1], 6)
        XCTAssertEqual(context[key2], 6)
        XCTAssertEqual(context[key3], 6)
    }
}
