//
//  Variable.swift
//  Logician
//
//  Created by Matt Diephouse on 9/2/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

public protocol VariableProtocol: PropertyProtocol {
    /// The type of value that the variable represents.
    associatedtype Value
    
    /// Extracts the variable from the receiver.
    var variable: Variable<Value> { get }
}

/// Type-erased information about a bijection created with `bimap`.
internal struct Bijection {
    /// A function that takes a state and attempts to return a state where a
    /// variable is unified based on the value of another variable.
    typealias Function = (State) throws -> State
    
    /// The variable that `bimap` was called on.
    var source: AnyVariable
    
    /// A function that takes a state and attempts to unify the derived variable
    /// with the corresponding value.
    var unifyDerived: Function
    
    /// A function that takes a state and attempts to unify `source` with the
    /// corresponding value.
    var unifySource: Function
    
    init<Source: Equatable, Derived: Equatable>(
        _ source: Variable<Source>,
        _ derived: AnyVariable,
        _ forward: @escaping (Source) -> Derived,
        _ backward: @escaping (Derived) -> Source
    ) {
        func unify<From: Equatable, To: Equatable>(
            _ lhs: AnyVariable,
            _ rhs: AnyVariable,
            _ transform: @escaping (From) -> To
            ) -> (State) throws -> State {
            return { state in
                guard let value = state.value(of: lhs) else { return state }
                return try state.unifying(rhs, transform(value as! From))
            }
        }
        
        self.source = source.erased
        unifyDerived = unify(source.erased, derived, forward)
        unifySource = unify(derived, source.erased, backward)
    }
}

extension VariableProtocol where Value: Equatable {
    /// Create a new variable that's related to this one by a transformation.
    public func bimap<A: Equatable>(
        forward: @escaping (Value) -> A,
        backward: @escaping (A) -> Value
    ) -> Variable<A> {
        let newVariable = AnyVariable()
        let bijection = Bijection(variable, newVariable, forward, backward)
        return Variable<A>(newVariable, bijection: bijection)
    }
}

/// An unknown value in a logic problem.
public struct Variable<Value> {
    /// A type-erased version of the variable.
    internal var erased: AnyVariable
    
    /// The bijection information if this variable was created with `bimap`.
    internal let bijection: Bijection?
    
    /// Create a new variable.
    public init() {
        self.init(AnyVariable())
    }
    
    /// Create a new variable.
    fileprivate init(_ erased: AnyVariable, bijection: Bijection? = nil) {
        self.erased = erased
        self.bijection = bijection
    }
}

extension Variable: VariableProtocol {
    public var property: Property<Value> {
        return Property(self, { $0 })
    }
    
    public var variable: Variable<Value> {
        return self
    }
}

/// A type-erased, hashable `Variable`.
internal class AnyVariable: Hashable {
    /// Create a variable.
    fileprivate init() { }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    static func ==(lhs: AnyVariable, rhs: AnyVariable) -> Bool {
        return lhs === rhs
    }
}

/// Test whether the variables have the same identity.
internal func == <Left, Right>(lhs: Variable<Left>, rhs: Variable<Right>) -> Bool {
    return lhs.erased == rhs.erased
}
