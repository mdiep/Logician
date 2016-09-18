//
//  Constraint.swift
//  Logician
//
//  Created by Matt Diephouse on 9/17/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

/// A constraint on the validity of a `State`.
internal typealias Constraint = (State) throws -> ()

/// Create an equality constraint between some properties and, optionally, a
/// value.
internal func equal<P: PropertyProtocol>(_ properties: [P], value: P.Value? = nil) -> Constraint where P.Value: Equatable {
    let properties = properties.map { $0.property }
    return { state in
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
}

/// Create an inequality constraint between some properties and, optionally, a
/// value.
internal func unequal<P: PropertyProtocol>(_ properties: [P], values: Set<P.Value> = []) -> Constraint where P.Value: Hashable {
    let properties = properties.map { $0.property }
    return { state in
        var values = values
        for p in properties {
            guard let p = state.value(of: p) else { continue }
            
            if values.contains(p) {
                throw Error.UnificationError
            }
            values.insert(p)
        }
    }
}
