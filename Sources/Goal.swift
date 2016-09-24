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
/// Represented as a function that takes a produces a generator of states that
/// are compatible with the goal.
public typealias Goal = (State) -> Generator<State>

/// Create a `Goal` with a block that tries to transform a state. If the block
/// throws, an empty generator will be returned, signaling a deadend.
private func goal(_ block: @escaping (State) throws -> (State)) -> Goal {
    return { state in
        do {
            let state = try block(state)
            return Generator(values: [ state ])
        } catch {
            return Generator()
        }
    }
}

/// Create a `Goal` that enforces a constraint
private func goal(_ constraint: @escaping Constraint) -> Goal {
    return goal { try $0.constraining(constraint) }
}


// MARK: - Equality

/// A goal that's satisfied when a variable equals a value.
public func == <V: VariableProtocol>(variable: V, value: V.Value) -> Goal where V.Value: Equatable {
    return goal { try $0.unifying(variable.variable, value) }
}

/// A goal that's satisfied when a value equals a variable.
public func == <V: VariableProtocol>(value: V.Value, variable: V) -> Goal where V.Value: Equatable {
    return variable == value
}

/// A goal that's satisfied when two variables are equal.
public func == <V: VariableProtocol>(lhs: V, rhs: V) -> Goal where V.Value: Equatable {
    return goal { try $0.unifying(lhs.variable, rhs.variable) }
}

/// A goal that's satisfied when a property equals a value.
public func == <Value: Equatable>(property: Property<Value>, value: Value) -> Goal {
    return goal(equal([ property ], value: value))
}

/// A goal that's satisfied when a property equals a value.
public func == <Value: Equatable>(value: Value, property: Property<Value>) -> Goal {
    return property == value
}

/// A goal that's satisfied when two properties are equal.
public func == <P: PropertyProtocol>(lhs: P, rhs: P) -> Goal where P.Value: Equatable {
    return goal(equal([ lhs, rhs ]))
}


// MARK: - Inequality

/// A goal that's satisfied when a property doesn't equal a value.
public func != <Value: Hashable>(property: Property<Value>, value: Value) -> Goal {
    return goal(unequal([ property ], values: Set([ value ])))
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
    return goal(unequal([ lhs, rhs ]))
}

/// A goal that's satisfied when two variables aren't equal.
public func != <Value: Hashable>(lhs: Variable<Value>, rhs: Variable<Value>) -> Goal {
    return lhs.property != rhs.property
}

/// A goal that's satisfied when a variable and a property aren't equal.
public func != <Value: Hashable>(lhs: Variable<Value>, rhs: Property<Value>) -> Goal {
    return lhs.property != rhs
}

/// A goal that's satisfied when a variable and a property aren't equal.
public func != <Value: Hashable>(lhs: Property<Value>, rhs: Variable<Value>) -> Goal {
    return lhs != rhs.property
}

/// A goal that's satisfied when all the properties have different values.
public func distinct<P: PropertyProtocol>(_ properties: [P]) -> Goal where P.Value: Hashable {
    return goal(unequal(properties))
}

/// A goal that's satisfied when all the properties have different values.
public func distinct<P: PropertyProtocol>(_ properties: P...) -> Goal where P.Value: Hashable {
    return distinct(properties)
}


// MARK: - Logicial Conjunction

/// A goal that succeeds when all of the subgoals succeed.
public func all(_ goals: [Goal]) -> Goal {
    return { state in
        let initial = Generator<State>(values: [ state ])
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
        return Generator(interleaving: goals.map { $0(state) })
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
