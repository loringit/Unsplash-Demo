//
//  Atomic.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import Foundation

// This is a property wrapper that allows safe multithreading
// inspired by: https://www.vadimbulavin.com/swift-atomic-properties-with-property-wrappers/, but with single writer multiple reader

@propertyWrapper
public
class Atomic<Value> {
    private let queue = DispatchQueue(label: "com.unsplash.atomic", attributes: .concurrent)
    private var _value: Value

    public
    init(wrappedValue: Value) {
        self._value = wrappedValue
    }
    
    public var projectedValue: Atomic<Value> {
        return self
    }
    
    public
    func mutate(_ mutation: (inout Value) -> Void) {
        return queue.sync(flags: .barrier) {
            mutation(&self._value)
        }
    }
    
    public var wrappedValue: Value {
        get {
            return queue.sync { _value }
        }
        set {
            queue.sync(flags: .barrier) { _value = newValue }
        }
    }
    
    public var value: Value {
        return wrappedValue
    }
}
