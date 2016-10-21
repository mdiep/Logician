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
    associatedtype Value: Equatable
    
    /// Extracts the variable from the receiver.
    var variable: Variable<Value> { get }
}

/// A function that transforms a state based a bijection, throwing an error if
/// the bijection fails to unify.
internal typealias Bijection = (State) throws -> State

private func biject<From: Equatable, To: Equatable>(
    _ lhs: AnyVariable,
    _ rhs: AnyVariable,
    _ transform: @escaping (From) -> To
    ) -> Bijection {
    return { state in
        guard let value = state.value(of: lhs) else { return state }
        return try state.unifying(rhs, transform(value as! From))
    }
}

extension VariableProtocol {
    /// Create a new variable that's related to this one by a transformation.
    public func bimap<A: Equatable>(
        forward: @escaping (Value) -> A,
        backward: @escaping (A) -> Value
    ) -> Variable<A> {
        let source = variable.erased
        let a = AnyVariable(A.self)
        let bijections = [
            a: biject(source, a, forward),
            source: biject(a, source, backward),
        ]
        return Variable<A>(a, bijections: bijections)
    }
    
    /// Create a new variable that's related to this one by a transformation.
    ///
    /// - important: The `identity` must uniquely identify this bimap so that
    ///              Logician will know that the new variables are the same if
    ///              it's executed multiple times.
    ///
    /// - parameters:
    ///   - identity: A string that uniquely identifies this bimap.
    ///   - forward: A block that maps this value into two values.
    ///   - backward: A block that maps two values back into the this value.
    public func bimap<A: Hashable, B: Hashable>(
        identity: String,
        forward: @escaping (Value) -> (A, B),
        backward: @escaping ((A, B)) -> Value
    ) -> (Variable<A>, Variable<B>) {
        let source = variable.erased
        let a = AnyVariable(A.self, source, key: "\(identity).0")
        let b = AnyVariable(B.self, source, key: "\(identity).1")
        let unifySource: Bijection = { state in
            guard let aValue = state.value(of: a), let bValue = state.value(of: b) else {
                return state
            }
            return try state.unifying(source, backward((aValue as! A, bValue as! B)))
        }
        let bijections = [
            a: biject(source, a) { forward($0).0 },
            b: biject(source, b) { forward($0).1 },
            source: unifySource,
        ]
        return (
            Variable<A>(a, bijections: bijections),
            Variable<B>(b, bijections: bijections)
        )
    }
    
    /// Create a new variable that's related to this one by a transformation.
    ///
    /// - note: The location of this bimap in the source code determines its
    ///         identity. If you need it to live in multiple locations, you need
    ///         to specify an explicit identity.
    ///
    /// - parameters:
    ///   - identity: A string that uniquely identifies this bimap.
    ///   - forward: A block that maps this value into two values.
    ///   - backward: A block that maps two values back into the this value.
    public func bimap<A: Hashable, B: Hashable>(
        file: StaticString = #file,
        line: Int = #line,
        function: StaticString = #function,
        forward: @escaping (Value) -> (A, B),
        backward: @escaping ((A, B)) -> Value
    ) -> (Variable<A>, Variable<B>) {
        let identity = "\(file):\(line):\(function)"
        return bimap(identity: identity, forward: forward, backward: backward)
    }
}

/// An unknown value in a logic problem.
public struct Variable<Value: Equatable> {
    /// A type-erased version of the variable.
    internal var erased: AnyVariable
    
    /// The bijection information if this variable was created with `bimap`.
    internal let bijections: [AnyVariable: Bijection]
    
    /// Create a new variable.
    public init() {
        self.init(AnyVariable(Value.self))
    }
    
    /// Create a new variable.
    fileprivate init(_ erased: AnyVariable, bijections: [AnyVariable: Bijection] = [:]) {
        self.erased = erased
        self.bijections = bijections
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
    internal struct Basis {
        typealias Key = String
        let source: AnyVariable
        let key: Key
    }
    
    /// The basis of the variable if it is derived.
    internal let basis: Basis?
    
    /// A type-erased function that will test two values for equality.
    internal let equal: (Any, Any) -> Bool
    
    /// Create a new identity.
    fileprivate init<Value: Equatable>(_ type: Value.Type) {
        basis = nil
        self.equal = { ($0 as! Value) == ($1 as! Value) }
    }
    
    /// Create a variable based on another variable.
    fileprivate init<Value: Equatable>(
        _ type: Value.Type,
        _ source: AnyVariable,
        key: String
    ) {
        basis = Basis(source: source, key: key)
        self.equal = { ($0 as! Value) == ($1 as! Value) }
    }
    
    var hashValue: Int {
        if let basis = self.basis {
            return basis.source.hashValue ^ basis.key.hashValue
        } else {
            return ObjectIdentifier(self).hashValue
        }
    }
    
    static func ==(lhs: AnyVariable, rhs: AnyVariable) -> Bool {
        if let lhs = lhs.basis, let rhs = rhs.basis {
            return lhs.source == rhs.source && lhs.key == rhs.key
        } else {
            return lhs === rhs
        }
    }
}

/// Test whether the variables have the same identity.
internal func == <Left, Right>(lhs: Variable<Left>, rhs: Variable<Right>) -> Bool {
    return lhs.erased == rhs.erased
}
