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
    
    static func ==(lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}
