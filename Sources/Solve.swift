//
//  Solve.swift
//  Logician
//
//  Created by Matt Diephouse on 9/6/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

/// Solve a logic problem and return the value of a variable.
///
/// - parameters:
///   - block: A block that takes a variable and returns goals to satisfy.
///
/// - returns: A generator of values that satisfy the goals. If a goal is
///            satisfied, but the variable has no value, then that state will
///            be dropped.
public func solve<Value>(_ block: (Variable<Value>) -> Goal) -> Generator<Value> {
    let variable = Variable<Value>()
    return block(variable)(State())
        .flatMap { return $0.value(of: variable) }
}
