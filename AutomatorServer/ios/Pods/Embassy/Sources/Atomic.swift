//  Borrowed from https://github.com/ReactiveCocoa/ReactiveCocoa
//
//  Atomic.swift
//  ReactiveCocoa
//
//  Copyright (c) 2012 - 2016, GitHub, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Justin Spahr-Summers on 2014-06-10.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

import Foundation


/// An atomic variable.
final class Atomic<Value> {
    private var mutex = pthread_mutex_t()
    private var _value: Value

    /// Atomically gets or sets the value of the variable.
    var value: Value {
        get {
            return withValue { $0 }
        }

        set(newValue) {
            modify { _ in newValue }
        }
    }

    /// Initializes the variable with the given initial value.
    init(_ value: Value) {
        _value = value
        let result = pthread_mutex_init(&mutex, nil)
        assert(result == 0, "Failed to initialize mutex with error \(result).")
    }

    deinit {
        let result = pthread_mutex_destroy(&mutex)
        assert(result == 0, "Failed to destroy mutex with error \(result).")
    }

    private func lock() {
        let result = pthread_mutex_lock(&mutex)
        assert(result == 0, "Failed to lock \(self) with error \(result).")
    }

    private func unlock() {
        let result = pthread_mutex_unlock(&mutex)
        assert(result == 0, "Failed to unlock \(self) with error \(result).")
    }

    /// Atomically replaces the contents of the variable.
    ///
    /// Returns the old value.
    func swap(newValue: Value) -> Value {
        return modify { _ in newValue }
    }

    /// Atomically modifies the variable.
    ///
    /// Returns the old value.
    @discardableResult
    func modify(action: (Value) throws -> Value) rethrows -> Value {
        return try withValue { value in
            _value = try action(value)
            return value
        }
    }

    /// Atomically performs an arbitrary action using the current value of the
    /// variable.
    ///
    /// Returns the result of the action.
    func withValue<Result>(action: (Value) throws -> Result) rethrows -> Result {
        lock()
        defer { unlock() }

        return try action(_value)
    }
}
