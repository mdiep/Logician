//
//  Solve.swift
//  Logician
//
//  Created by Matt Diephouse on 9/6/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

public func solve<Value>(_ block: (Variable<Value>) -> Goal) -> AnyIterator<Value> {
    let variable = Variable<Value>()
    return block(variable)(State())
        .flatMap { return $0.value(of: variable) }
}
