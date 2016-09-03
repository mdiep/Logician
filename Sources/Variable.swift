//
//  Variable.swift
//  Logician
//
//  Created by Matt Diephouse on 9/2/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

/// A class used to provide identity to `Variable`s.
private class Identity { }

/// An unknown value in a logic problem.
public struct Variable<Value> {
    /// The identity of the variable.
    fileprivate let identity: Identity
    
    /// Create a new variable.
    public init() {
        self.init(identity: Identity())
    }
    
    /// Create a variable with an existing `Identity`.
    private init(identity: Identity) {
        self.identity = identity
    }
    
    /// A type-erased version of the variable.
    internal var erased: Variable<Any> {
        return Variable<Any>(identity: identity)
    }
}

/// Test whether the `Variable`s have the same identity.
internal func == <Left, Right>(lhs: Variable<Left>, rhs: Variable<Right>) -> Bool {
    return lhs.identity === rhs.identity
}
