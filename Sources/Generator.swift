//
//  Generator.swift
//  Logician
//
//  Created by Matt Diephouse on 9/17/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

/// A generator of `Value`s.
public class Generator<Value>: IteratorProtocol {
    /// The underlying iterator that powers the generator.
    private var iterator: AnyIterator<Value>
    
    /// Create a generator from an array of `Value`s.
    public init(values: [Value] = []) {
        iterator = AnyIterator(values.makeIterator())
    }

    /// Create a generator from a block that either returns a `Value` or returns
    /// `nil` if the output has been exhausted.
    public init(_ block: @escaping () -> Value?) {
        iterator = AnyIterator(block)
    }
    
    /// Returns the next value or returns `nil` if the output has been
    /// exhausted.
    public func next() -> Value? {
        return iterator.next()
    }
}

extension Generator {
    /// Returns all the remaining values in the generator.
    public func allValues() -> [Value] {
        var values: [Value] = []
        while let v = next() {
            values.append(v)
        }
        return values
    }
    
    /// Maps values in the generator to new values.
    public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Generator<NewValue> {
        return Generator<NewValue> {
            return self.next().map(transform)
        }
    }
}

extension Generator {
    /// Create an interator that iterleaves an array of generators.
    ///
    /// An element will be taken from each generator in sequence, until all
    /// generators are exhausted.
    convenience init(interleaving generators: [Generator<Value>]) {
        var generators = generators
        self.init {
            while let s = generators.first {
                generators.remove(at: 0)
                if let result = s.next() {
                    generators.append(s)
                    return result
                }
            }
            return nil
        }
    }
    
    /// Map a function over the values returned by the generator, flattening
    /// the resulting generator of optionals.
    func flatMap<NewValue>(_ transform: @escaping (Value) -> NewValue?) -> Generator<NewValue> {
        return Generator<NewValue> {
            while let input = self.next() {
                if let result = transform(input) {
                    return result
                }
            }
            return nil
        }
    }
    
    /// Map a function over the elements returned by the generator, flattening
    /// the resulting generator of generators.
    func flatMap(_ transform: @escaping (Value) -> Generator<Value>) -> Generator<Value> {
        var inner = self.next().map(transform)
        return Generator {
            while let i = inner {
                if let result = i.next() {
                    return result
                }
                inner = self.next().map(transform)
            }
            return nil
        }
    }
}
