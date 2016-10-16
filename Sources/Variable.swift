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
    /// A function that takes a state and a value and attempts to return a state
    /// where a variable is unified with that value.
    typealias Function = (State, Any) throws -> State
    
    /// The variable that was created with `bimap`.
    var x: AnyVariable
    
    /// The variable that `bimap` was called on.
    var y: AnyVariable
    
    /// A function that takes state and a value of `y`, and attempts to unify
    /// `x` with the corresponding value.
    var toX: Function
    
    /// A function that takes state and a value of `x`, and attempts to unify
    /// `y` with the corresponding value.
    var toY: Function
}

extension VariableProtocol where Value: Equatable {
    /// Create a new variable that's related to this one by a transformation.
    public func bimap<A: Equatable>(
        forward: @escaping (Value) -> A,
        backward: @escaping (A) -> Value
    ) -> Variable<A> {
        let variable = AnyVariable()
        let bijection = Bijection(
            x: variable,
            y: self.variable.erased,
            toX: { state, value in
                return try state.unifying(variable, forward(value as! Value))
            },
            toY: { state, value in
                return try state.unifying(self.variable, backward(value as! A))
            }
        )
        return Variable<A>(variable, bijection: bijection)
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
