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
    /// Type-erased information about a set of unified variables.
    private struct Info {
        /// The value of the variables, if any.
        var value: Any?
        
        /// Mapping from a key to the derived variable.
        ///
        /// All variables that share the same basis must be unified.
        var derived: [AnyVariable.Basis.Key: AnyVariable] = [:]
        
        /// Functions that unify variables from bijections.
        var bijections: [AnyVariable: Bijection]
        
        init(_ bijections: [AnyVariable: Bijection] = [:]) {
            self.bijections = bijections
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
        return try! bijecting(variable)
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
    private func bijecting<Value>(_ variable: Variable<Value>) throws -> State {
        // We've already gone through this for this variable
        if context[variable.erased] != nil { return self }
        
        // This isn't a bijection.
        if variable.bijections.isEmpty { return self }
        
        var state = self
        
        // If the variable doesn't have a basis, then this *must* be a 1-to-1
        // bijection. So the source is the variable that isn't passed in.
        let source = variable.erased.basis?.source
            ?? variable.bijections.keys.first { $0 != variable.erased }!
        let unifySource = variable.bijections[source]!
        
        // Unify all derived variables that share the same key. They are, by
        // definition, unified.
        var info = state.context[source] ?? Info()
        for (variable, bijection) in variable.bijections {
            if variable == source { continue }
            
            info.bijections[variable] = bijection
            if let key = variable.basis?.key {
                if let existing = info.derived[key] {
                    // Since variable is new, it can't have a value. So just
                    // assume the existing variable's info.
                    state.context.merge(existing, variable) { lhs, _ in lhs }
                } else {
                    info.derived[key] = variable
                    state.context[variable] = Info([source: unifySource])
                }
            } else {
                state.context[variable] = Info([source: unifySource])
            }
        }
        state.context[source] = info
        
        // Try to unify each bijection
        for bijection in variable.bijections.values {
            state = try bijection(state)
        }
        try state.verifyConstraints()
        
        return state
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
    public mutating func unify<Value>(_ variable: Variable<Value>, _ value: Value) throws {
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
    public func unifying<Value>(_ variable: Variable<Value>, _ value: Value) throws -> State {
        return try bijecting(variable)
            .unifying(variable.erased, value)
    }
    
    /// Unify a variable with a value.
    ///
    /// - important: `value` must be of the same type as `variable`'s `Value`.
    ///
    /// - parameters:
    ///   - variable: The variable to unify
    ///   - value: The value to give the variable
    ///
    /// - note: `throws` if `variable` already has a different value.
    internal mutating func unify(_ variable: AnyVariable, _ value: Any) throws {
        self = try unifying(variable, value)
    }
    
    /// Unify a variable with a value.
    ///
    /// - important: `value` must be of the same type as `variable`'s `Value`.
    ///
    /// - parameters:
    ///   - variable: The variable to unify
    ///   - value: The value to give the variable
    ///
    /// - returns: The unified state.
    ///
    /// - note: `throws` if `variable` already has a different value.
    internal func unifying(_ variable: AnyVariable, _ value: Any) throws -> State {
        var state = self
        
        var info = state.context[variable] ?? Info()
        if let oldValue = info.value {
            if !variable.equal(oldValue, value) {
                throw Error.UnificationError
            }
        } else {
            info.value = value
            state.context[variable] = info
            
            for unify in info.bijections.values {
                state = try unify(state)
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
    public mutating func unify<Value>(_ lhs: Variable<Value>, _ rhs: Variable<Value>) throws {
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
    public func unifying<Value>(_ lhs: Variable<Value>, _ rhs: Variable<Value>) throws -> State {
        return try self
            .bijecting(lhs)
            .bijecting(rhs)
            .unifying(lhs.erased, rhs.erased)
    }
    
    /// Unify two variables.
    ///
    /// - important: The two variables must have the same `Value` type.
    ///
    /// - parameters:
    ///   - lhs: The first variable to unify
    ///   - rhs: The second variable to unify
    ///
    /// - note: `throws` if the variables have existing, inequal values.
    internal mutating func unify(_ lhs: AnyVariable, _ rhs: AnyVariable) throws {
        self = try unifying(lhs, rhs)
    }
    
    /// Unify two variables.
    ///
    /// - important: The two variables must have the same `Value` type.
    ///
    /// - parameters:
    ///   - lhs: The first variable to unify
    ///   - rhs: The second variable to unify
    ///
    /// - returns: The unified state.
    ///
    /// - note: `throws` if `variable` already has a different value.
    internal func unifying(_ lhs: AnyVariable, _ rhs: AnyVariable) throws -> State {
        func merge<Key, Value>(
            _ a: [Key: Value]?,
            _ b: [Key: Value]?,
            combine: (Value, Value) -> Value
        ) -> [Key: Value] {
            var result: [Key: Value] = [:]
            var allKeys = Set<Key>()
            if let a = a?.keys { allKeys.formUnion(a) }
            if let b = b?.keys { allKeys.formUnion(b) }
            for key in allKeys {
                let a = a?[key]
                let b = b?[key]
                if let a = a, let b = b {
                    result[key] = combine(a, b)
                } else {
                    result[key] = a ?? b
                }
            }
            return result
        }
        
        let equal = lhs.equal
        var state = self
        var unify: [(AnyVariable, AnyVariable)] = []
        try state.context.merge(lhs, rhs) { lhs, rhs in
            if let left = lhs?.value, let right = rhs?.value, !equal(left, right) {
                throw Error.UnificationError
            }
            
            var info = Info()
            info.value = lhs?.value ?? rhs?.value
            info.bijections = merge(lhs?.bijections, rhs?.bijections) { a, _ in a }
            info.derived = merge(lhs?.derived, rhs?.derived) { a, b in
                unify.append((a, b))
                return a
            }
            return info
        }
        
        for (a, b) in unify {
            try state.unify(a, b)
        }
        
        let info = state.context[lhs]!
        for bijection in info.bijections.values {
            state = try bijection(state)
        }
        
        try state.verifyConstraints()
        return state
    }
}
