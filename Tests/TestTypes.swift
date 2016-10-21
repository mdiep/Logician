//
//  TestTypes.swift
//  Logician
//
//  Created by Matt Diephouse on 10/16/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import Logician

struct Point: Equatable {
    var x: Int
    var y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    static func ==(lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension VariableProtocol where Value == Point {
    private var parts: (Variable<Int>, Variable<Int>) {
        return bimap(
            forward: { ($0.x, $0.y) },
            backward: { Point($0.0, $0.1) }
        )
    }
    
    var x: Variable<Int> { return parts.0 }
    var y: Variable<Int> { return parts.1 }
}
