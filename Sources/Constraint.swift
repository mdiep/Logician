//
//  Constraint.swift
//  Logician
//
//  Created by Matt Diephouse on 9/17/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

/// A constraint on the validity of a `State`.
internal enum Constraint {
    /// A function that tests whether the constraint is met, throwing an error
    /// if it's not.
    typealias Test = (State) throws -> ()
    
    /// An equality constraint comprised of variables that affect it and a test.
    case equal(Set<AnyVariable>, Test)
    
    /// Test the constraint against a `State`, throwing an error if it's not
    /// met.
    func enforce(_ state: State) throws {
        switch self {
        case let .equal(_, test):
            try test(state)
        }
    }
}

/// Create an equality constraint between some variables and, optionally, a
/// value.
internal func equal<V: VariableProtocol>(_ variables: [V], value: V.Value? = nil) -> Constraint where V.Value: Equatable {
    let variables = variables.map { $0.variable }
    let test: Constraint.Test = { state in
        var value = value
        for v in variables {
            guard let v = state.value(of: v) else { continue }
            
            if value == nil {
                value = v
            }
            
            if value != v {
                throw Error.UnificationError
            }
        }
    }
    return .equal(Set(variables.map { $0.erased }), test)
}
