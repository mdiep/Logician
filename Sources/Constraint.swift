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

/// Create an equality constraint between some properties and, optionally, a
/// value.
internal func equal<P: PropertyProtocol>(_ properties: [P], value: P.Value? = nil) -> Constraint where P.Value: Equatable {
    let properties = properties.map { $0.property }
    let variables = Set(properties.map { $0.variable })
    let test: Constraint.Test = { state in
        var value = value
        for p in properties {
            guard let p = state.value(of: p) else { continue }
            
            if value == nil {
                value = p
            }
            
            if value != p {
                throw Error.UnificationError
            }
        }
    }
    return .equal(variables, test)
}
