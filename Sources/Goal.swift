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
public func == <Value: Equatable>(variable: Variable<Value>, value: Value) -> Goal {
    return { state in
        do {
            return AnyIterator(values: [ try state.unifying(variable, value) ])
        } catch {
            return AnyIterator(values: [])
        }
    }
}

/// A goal that's satisfied when a value equals a variable.
public func == <Value: Equatable>(value: Value, variable: Variable<Value>) -> Goal {
    return variable == value
}

/// A goal that's satisfied when two variables are equal.
public func == <Value: Equatable>(lhs: Variable<Value>, rhs: Variable<Value>) -> Goal {
    return { state in
        do {
            return AnyIterator(values: [ try state.unifying(lhs, rhs) ])
        } catch {
            return AnyIterator(values: [])
        }
    }
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
