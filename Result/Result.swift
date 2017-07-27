//
// Result.swift
//
// Copyright (c) 2017 Robert Brown
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

public enum Result<T> {
    case Success(() -> T)
    case Failure(() -> Error)
    
    public var value: T? {
        switch self {
        case let .Success(value): return value()
        case .Failure:            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .Success:            return nil
        case let .Failure(error): return error()
        }
    }
    
    public init(_ value: T) {
        self = .Success({ value })
    }
    
    public init(error: Error) {
        self = .Failure({ error })
    }
    
    public func map<U>(function: (T) -> U) -> Result<U> {
        return flatMap { Result<U>(function($0)) }
    }
    
    public func lazyMap<U>(function: @escaping (T) -> U) -> Result<U> {
        switch self {
        case let .Success(value): return .Success({ function(value()) })
        case let .Failure(error): return .Failure(error)
        }
    }
    
    public func tryMap<U>(function: (T) throws -> U) -> Result<U> {
        return flatMap { value in
            do {
                let newValue = try function(value)
                return .Success({ newValue })
            }
            catch {
                return .Failure({ error })
            }
        }
    }
    
    public func flatMap<U>(function: (T) -> Result<U>) -> Result<U> {
        switch self {
        case let .Success(value): return function(value())
        case let .Failure(error): return .Failure(error)
        }
    }
    
    public func withDefault(defaultValue: T) -> T {
        return value ?? defaultValue
    }
}

public func ==<T: Equatable>(lhs: Result<T>, rhs: Result<T>) -> Bool {
    return lhs.value == rhs.value
}

public func !=<T: Equatable>(lhs: Result<T>, rhs: Result<T>) -> Bool {
    return !(lhs == rhs)
}

public func ??<T>(lhs: Result<T>, rhs: Result<T>) -> Result<T> {
    switch lhs {
    case .Success: return lhs
    case .Failure: return rhs
    }
}
