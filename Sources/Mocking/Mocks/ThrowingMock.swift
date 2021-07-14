//
//  ThrowingMock.swift
//  
//
//  Created by Joel Saltzman on 5/23/21.
//

import Foundation

/// Mock a throwing function and store it's usage history.
@propertyWrapper public final class ThrowingMock<Context, Value>: Mockable {

    /// Get direct access the underlying ThrowingMock object.
    public var projectedValue: ThrowingMock<Context, Value> { return self }
    
    /// Stores the input and output of the when the Mock gets a value.
    public var usage: MockUsage<Context, Value>
    
    /// The initial close that the Mock was setup with.
    public var defaultValueLoader: (Context) throws -> Value
    
    /// Use to the current value load to get an expected value.
    public var wrappedValue: (Context) throws -> Value {
        get {
            return getValue
        }
        set {
            currentValueLoader = newValue
        }
    }
    
    /// This will either be the `defaultValueLoader` from when you initialized the ThrowingMock.
    /// Or this will be a custom one for mocking expected values.
    var currentValueLoader: (Context) throws -> Value
    
    /// Initial the Mock with a default value loader.
    /// - Parameter valueLoader: A closure to return a value. This is typically the live version of the function. You can override this later and reset back to this original value loader.
    public init(wrappedValue: @escaping (Context) throws -> Value) {
        self.usage = MockUsage()
        self.defaultValueLoader = wrappedValue
        self.currentValueLoader = wrappedValue
    }
    
    /// Get a value from the current value loader
    /// - Parameter context: The context required by the closure to get the value.
    /// - Returns: The value from the value loader.
    public func getValue(_ context: Context) throws -> Value {
        let result: Value
        do {
            result = try currentValueLoader(context)
            usage.addResult(context: context, value: result)
        } catch {
            usage.addError(context: context, error: error)
            throw error
        }
        return result
    }
    
    /// Reset the value loader to the default one used when the Mock was created.
    public func resetLoader() {
        self.wrappedValue = defaultValueLoader
    }
}
