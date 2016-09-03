//
//  Variable.swift
//  Logician
//
//  Created by Matt Diephouse on 9/2/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

private class Identity { }

public struct Variable<Value> {
    fileprivate let identity: Identity
    
    public init() {
        self.init(identity: Identity())
    }
    
    private init(identity: Identity) {
        self.identity = identity
    }
    
    internal var erased: Variable<Any> {
        return Variable<Any>(identity: identity)
    }
}

internal func == <Left, Right>(lhs: Variable<Left>, rhs: Variable<Right>) -> Bool {
    return lhs.identity === rhs.identity
}
