//
//  Goal.swift
//  Logician
//
//  Created by Matt Diephouse on 9/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

/// A desired logicial statement.
///
/// Represented as a function that takes a produces a stream of states that are
/// compatible with the goal.
public typealias Goal = (State) -> AnyIterator<State>


// MARK: - Equality

/// A goal that's satisfied when a variable equals a value.
public func == <V: VariableProtocol>(variable: V, value: V.Value) -> Goal where V.Value: Equatable {
    return { state in
        do {
            return AnyIterator(values: [ try state.unifying(variable.variable, value) ])
        } catch {
            return AnyIterator(values: [])
        }
    }
}

/// A goal that's satisfied when a value equals a variable.
public func == <V: VariableProtocol>(value: V.Value, variable: V) -> Goal where V.Value: Equatable {
    return variable == value
}

/// A goal that's satisfied when two variables are equal.
public func == <V: VariableProtocol>(lhs: V, rhs: V) -> Goal where V.Value: Equatable {
    return { state in
        do {
            return AnyIterator(values: [ try state.unifying(lhs.variable, rhs.variable) ])
        } catch {
            return AnyIterator(values: [])
        }
    }
}

/// A goal that's satisfied when a property equals a value.
public func == <Value: Equatable>(property: Property<Value>, value: Value) -> Goal {
    let constraint = equal([ property ], value: value)
    return { state in
        do {
            return AnyIterator(values: [ try state.constraining(constraint) ])
        } catch {
            return AnyIterator(values: [])
        }
    }
}

/// A goal that's satisfied when a property equals a value.
public func == <Value: Equatable>(value: Value, property: Property<Value>) -> Goal {
    return property == value
}

/// A goal that's satisfied when two properties are equal.
public func == <P: PropertyProtocol>(lhs: P, rhs: P) -> Goal where P.Value: Equatable {
    let constraint = equal([ lhs, rhs ])
    return { state in
        do {
            return AnyIterator(values: [ try state.constraining(constraint) ])
        } catch {
            return AnyIterator(values: [])
        }
    }
}


// MARK: - Inequality

/// A goal that's satisfied when a property doesn't equal a value.
public func != <Value: Hashable>(property: Property<Value>, value: Value) -> Goal {
    let constraint = unequal([ property ], values: Set([ value ]))
    return { state in
        do {
            return AnyIterator(values: [ try state.constraining(constraint) ])
        } catch {
            return AnyIterator(values: [])
        }
    }
}

/// A goal that's satisfied when a property doesn't equal a value.
public func != <Value: Hashable>(value: Value, property: Property<Value>) -> Goal {
    return property != value
}

/// A goal that's satisfied when a property doesn't equal a value.
public func != <Value: Hashable>(variable: Variable<Value>, value: Value) -> Goal {
    return variable.property != value
}

/// A goal that's satisfied when a property doesn't equal a value.
public func != <Value: Hashable>(value: Value, variable: Variable<Value>) -> Goal {
    return variable.property != value
}

/// A goal that's satisfied when two properties aren't equal.
public func != <Value: Hashable>(lhs: Property<Value>, rhs: Property<Value>) -> Goal {
    let constraint = unequal([ lhs, rhs ])
    return { state in
        do {
            return AnyIterator(values: [ try state.constraining(constraint) ])
        } catch {
            return AnyIterator(values: [])
        }
    }
}

/// A goal that's satisfied when two variables aren't equal.
public func != <Value: Hashable>(lhs: Variable<Value>, rhs: Variable<Value>) -> Goal {
    return lhs.property != rhs.property
}

/// A goal that's satisfied when a variable and a property aren't equal.
public func != <Value: Hashable>(lhs: Variable<Value>, rhs: Property<Value>) -> Goal {
    return lhs.property != rhs
}

/// A goal that's satisfied when a variale and a property aren't equal.
public func != <Value: Hashable>(lhs: Property<Value>, rhs: Variable<Value>) -> Goal {
    return lhs != rhs.property
}

// MARK: - Logicial Conjunction

/// A goal that succeeds when all of the subgoals succeed.
public func all(_ goals: [Goal]) -> Goal {
    return { state in
        let initial = AnyIterator<State>(values: [ state ])
        return goals.reduce(initial) { $0.flatMap($1) }
    }
}

/// A goal that succeeds when all of the subgoals succeed.
public func all(_ goals: @escaping Goal...) -> Goal {
    return all(goals)
}

/// A goal that succeeds when both of the subgoals succeed.
public func &&(lhs: @escaping Goal, rhs: @escaping Goal) -> Goal {
    return all(lhs, rhs)
}


// MARK: - Logicial Disjunction

/// A goal that succeeds when any of the subgoals succeeds.
///
/// This can multiple alternative solutions.
public func any(_ goals: [Goal]) -> Goal {
    return { state in
        return AnyIterator(interleaving: goals.map { $0(state) })
    }
}

/// A goal that succeeds when any of the subgoals succeeds.
///
/// This can multiple alternative solutions.
public func any(_ goals: @escaping Goal...) -> Goal {
    return any(goals)
}

/// A goal that succeeds when either of the subgoals succeeds.
///
/// This can multiple alternative solutions.
public func ||(lhs: @escaping Goal, rhs: @escaping Goal) -> Goal {
    return any(lhs, rhs)
}
