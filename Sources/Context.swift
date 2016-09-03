//
//  Context.swift
//  Logician
//
//  Created by Matt Diephouse on 9/1/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

private class Node<Key: Hashable, Value> {
    var keys: Set<Key>
    var value: Value?
    
    init(keys: Set<Key>, value: Value?) {
        self.keys = keys
        self.value = value
    }
}

internal struct Context<Key: Hashable, Value> {
    private var values: [Key: Node<Key, Value>] = [:]
    
    subscript(_ key: Key) -> Value? {
        get {
            return values[key]?.value
        }
        set(newValue) {
            updateValue(newValue, forKey: key)
        }
    }
    
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
    
    mutating func removeValue(forKey key: Key) {
        values.removeValue(forKey: key)
    }
    
    @discardableResult
    mutating func updateValue(_ newValue: Value?, forKey key: Key) -> Value? {
        return updateValue(forKey: key) { _ in newValue }
    }
    
    @discardableResult
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
