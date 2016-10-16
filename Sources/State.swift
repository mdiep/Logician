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
    /// Information about a set of unified variables.
    private struct Info {
        /// The value of the variables, if any.
        var value: Any?
        
        /// Functions that unify variables from bijections.
        var transforms: [(State) throws -> State] = []
        
        /// The value of the variables, if any, casted to `Value`.
        func value<Value>(_ type: Value.Type) -> Value? {
            return value.map { $0 as! Value }
        }
    }
    
    /// The data backing the state.
    private var context = Context<AnyVariable, Info>()
    
    /// The constraints on the state.
    private var constraints: [Constraint] = []
    
    /// Look up the value of a property.
    ///
    /// - parameters:
    ///   - property: A property of a variable in the state
    ///
    /// - returns: The value of the property, or `nil` if the value is unknown
    ///            or the variable isn't in the `State`.
    public func value<Value>(of property: Property<Value>) -> Value? {
        return value(of: property.variable)
            .map { property.transform($0) as! Value }
    }
    
    /// Look up the value of a variable.
    ///
    /// - parameters:
    ///   - variable: A variable in the state
    ///
    /// - returns: The value of the variable, or `nil` if the value is unknown
    ///            or the variable isn't in the `State`.
    internal func value(of variable: AnyVariable) -> Any? {
        return context[variable]?.value
    }
    
    /// Look up the value of a variable.
    ///
    /// - parameters:
    ///   - variable: A variable in the state
    ///
    /// - returns: The value of the variable, or `nil` if the value is unknown
    ///            or the variable isn't in the `State`.
    public func value<Value>(of variable: Variable<Value>) -> Value? {
        // ! because asking for the value of a variable can't change it
        return try! adding(bijection: variable.bijection, from: variable.erased)
            .value(of: variable.erased)
            .map { $0 as! Value }
    }
    
    /// Add a constraint to the state.
    internal mutating func constrain(_ constraint: @escaping Constraint) throws {
        try constraint(self)
        constraints.append(constraint)
    }
    
    /// Add a constraint to the state.
    internal func constraining(_ constraint: @escaping Constraint) throws -> State {
        var state = self
        try state.constrain(constraint)
        return state
    }
    
    /// Add a bijection to the state, unifying the variable it came from if the
    /// other variable has a value.
    private func adding(bijection: Bijection?, from variable: AnyVariable) throws -> State {
        guard let bijection = bijection else { return self }
        if context[variable] != nil { return self }
        
        var state = self
        var info = Info()
        info.transforms.append(bijection.unifySource)
        state.context[variable] = info
        
        state.context.updateValue(forKey: bijection.source) { info in
            var info = info ?? Info()
            info.transforms.append(bijection.unifyDerived)
            return info
        }
        
        return try bijection.unifyDerived(state)
    }
    
    /// Verify that all the constraints in the state have been maintained,
    /// throwing if any have been violated.
    private func verifyConstraints() throws {
        for constraint in constraints {
            try constraint(self)
        }
    }
    
    /// Unify a variable with a value.
    ///
    /// - parameters:
    ///   - variable: The variable to unify
    ///   - value: The value to give the variable
    ///
    /// - note: `throws` if `variable` already has a different value.
    public mutating func unify<Value: Equatable>(_ variable: Variable<Value>, _ value: Value) throws {
        self = try unifying(variable, value)
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
        return try adding(bijection: variable.bijection, from: variable.erased)
            .unifying(variable.erased, value)
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
    internal func unifying<Value: Equatable>(_ variable: AnyVariable, _ value: Value) throws -> State {
        var state = self
        
        var info = state.context[variable] ?? Info()
        if let oldValue = info.value(Value.self) {
            if oldValue != value {
                throw Error.UnificationError
            }
        } else {
            info.value = value
            state.context[variable] = info
            
            for transform in info.transforms {
                state = try transform(state)
            }
            try state.verifyConstraints()
        }
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
        self = try unifying(lhs, rhs)
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
        var state = try self
            .adding(bijection: lhs.bijection, from: lhs.erased)
            .adding(bijection: rhs.bijection, from: rhs.erased)
        try state.context.merge(lhs.erased, rhs.erased) { lhs, rhs in
            if let lhs = lhs?.value(Value.self), let rhs = rhs?.value(Value.self), lhs != rhs {
                throw Error.UnificationError
            }
            
            var info = Info()
            info.value = lhs?.value ?? rhs?.value
            info.transforms.append(contentsOf: lhs?.transforms ?? [])
            info.transforms.append(contentsOf: rhs?.transforms ?? [])
            return info
        }
        
        let info = state.context[lhs.erased]!
        for transform in info.transforms {
            state = try transform(state)
        }
        
        try state.verifyConstraints()
        return state
    }
}
