//
//  State.swift
//  Logician
//
//  Created by Matt Diephouse on 9/2/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

public enum Error: Swift.Error {
    case UnificationError
}

/// A partial or complete solution to a logic problem.
public struct State {
    private var context = Context<AnyVariable, Any>()
    
    /// Look up the value of a variable.
    ///
    /// - parameters:
    ///   - variable: A variable in the state
    ///
    /// - returns: The value of the variable, or `nil` if the value is unknown
    ///            or the variable isn't in the `State`.
    public func value<Value>(of variable: Variable<Value>) -> Value? {
        return context[variable.erased].map { $0 as! Value }
    }
    
    /// Unify a variable with a value.
    ///
    /// - parameters:
    ///   - variable: The variable to unify
    ///   - value: The value to give the variable
    ///
    /// - note: `throws` if `variable` already has a different value.
    public mutating func unify<Value: Equatable>(_ variable: Variable<Value>, _ value: Value) throws {
        try context.updateValue(forKey: variable.erased) { oldValue in
            if let oldValue = oldValue.map({ $0 as! Value }), oldValue != value {
                throw Error.UnificationError
            }
            
            return value
        }
    }
    
    /// Unify a variable with a value.
    ///
    /// - parameters:
    ///   - variable: The variable to unify
    ///   - value: The value to give the variable
    ///
    /// - returns: The unified state.
    ///
    /// - note: `throws` if `variable` already has a different value.
    public func unifying<Value: Equatable>(_ variable: Variable<Value>, _ value: Value) throws -> State {
        var state = self
        try state.unify(variable, value)
        return state
    }
    
    /// Unify two variables.
    ///
    /// - parameters:
    ///   - lhs: The first variable to unify
    ///   - rhs: The second variable to unify
    ///
    /// - note: `throws` if the variables have existing, inequal values.
    public mutating func unify<Value: Equatable>(_ lhs: Variable<Value>, _ rhs: Variable<Value>) throws {
        try context.merge(lhs.erased, rhs.erased) { lhs, rhs in
            if let lhs = lhs as! Value?, let rhs = rhs as! Value?, lhs != rhs {
                throw Error.UnificationError
            }
            
            return lhs ?? rhs
        }
    }
    
    /// Unify two variables.
    ///
    /// - parameters:
    ///   - lhs: The first variable to unify
    ///   - rhs: The second variable to unify
    ///
    /// - returns: The unified state.
    ///
    /// - note: `throws` if `variable` already has a different value.
    public func unifying<Value: Equatable>(_ lhs: Variable<Value>, _ rhs: Variable<Value>) throws -> State {
        var state = self
        try state.unify(lhs, rhs)
        return state
    }
}
