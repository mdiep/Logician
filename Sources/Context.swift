//
//  Context.swift
//  Logician
//
//  Created by Matt Diephouse on 9/1/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

/// A reference type that unifies a set of keys.
private class Node<Key: Hashable, Value> {
    /// The keys that point to this node.
    var keys: Set<Key>
    
    /// The value for the unified keys.
    var value: Value?
    
    /// Create a node.
    ///
    /// - parameters:
    ///   - keys: The keys that point to this node
    ///   - value: The value for the unified keys
    init(keys: Set<Key>, value: Value?) {
        self.keys = keys
        self.value = value
    }
}

/// An associative collection where multiple keys share a value.
internal struct Context<Key: Hashable, Value> {
    private var values: [Key: Node<Key, Value>] = [:]
    
    /// Lookup or set a value for a key.
    ///
    /// This will update the value of all the linked keys.
    ///
    /// - note: Setting `nil` will clear the value, but not delete the keys.
    subscript(_ key: Key) -> Value? {
        get {
            return values[key]?.value
        }
        set(newValue) {
            updateValue(newValue, forKey: key)
        }
    }
    
    /// Merge two sets of keys.
    ///
    /// - parameters:
    ///   - key1: The first key to merge
    ///   - key2: The second key to merge
    ///   - combine: A block to combine the two values into a single value
    mutating func merge(_ key1: Key, _ key2: Key, combine: (Value?, Value?) throws -> Value?) rethrows {
        let node1 = values[key1]
        let node2 = values[key2]
        let newValue = try combine(node1?.value, node2?.value)
        let allKeys = (node1?.keys ?? Set()).union(node2?.keys ?? Set()).union([ key1, key2 ])
        let node = Node(keys: allKeys, value: newValue)
        for key in allKeys {
            values[key] = node
        }
    }
    
    /// Remove a key from the context.
    ///
    /// - note: This will clear this key's association with any linked keys, but
    ///         will not remove the linked keys themselves.
    mutating func removeValue(forKey key: Key) {
        values.removeValue(forKey: key)
    }
    
    /// Upbate the value of a key.
    ///
    /// - parameters:
    ///   - newValue: The new value to give the linked keys
    ///   - key: Any key
    ///
    /// - returns: The previous value of `key`, if any.
    @discardableResult
    mutating func updateValue(_ newValue: Value?, forKey key: Key) -> Value? {
        return updateValue(forKey: key) { _ in newValue }
    }
    
    /// Upbate the value of a key.
    ///
    /// - parameters:
    ///   - newValue: The new value to give the linked keys
    ///   - transform: A block that takes the current value and returns a new
    ///                one.
    ///
    /// - returns: The previous value of `key`, if any.    @discardableResult
    mutating func updateValue(forKey key: Key, transform: (Value?) throws -> Value?) rethrows -> Value? {
        let node = values[key]
        let oldValue = node?.value
        let newValue = try transform(oldValue)
        if let node = node {
            node.value = newValue
        } else {
            values[key] = Node(keys: Set([ key ]), value: newValue)
        }
        return oldValue
    }
}
