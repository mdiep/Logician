//
//  AnyIterator.swift
//  Logician
//
//  Created by Matt Diephouse on 9/4/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

internal extension AnyIterator {
    /// Create an iterator from an array of values.
    init(values: [Element]) {
        self.init(values.makeIterator())
    }
    
    /// Create an interator that iterleaves an array of iterators.
    ///
    /// An element will be taken from each iterator in sequence, until all
    /// iterators are exhausted.
    init<I: IteratorProtocol>(interleaving iterators: [I]) where I.Element == Element {
        var iterators = iterators
        self.init {
            while var i = iterators.first {
                iterators.remove(at: 0)
                if let result = i.next() {
                    iterators.append(i)
                    return result
                }
            }
            return nil
        }
    }
    
    /// Map a function over the elements returned by the iterator, flattening
    /// the resulting iterator of optionals.
    func flatMap<Value>(_ transform: @escaping (Element) -> Value?) -> AnyIterator<Value> {
        return AnyIterator<Value> {
            while let input = self.next() {
                if let result = transform(input) {
                    return result
                }
            }
            return nil
        }
    }
    
    /// Map a function over the elements returned by the iterator, flattening
    /// the resulting iterator of iterators.
    func flatMap(_ transform: @escaping (Element) -> AnyIterator<Element>) -> AnyIterator<Element> {
        var inner = self.next().map(transform)
        return AnyIterator {
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
