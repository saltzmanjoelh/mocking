//
//  Mock.swift
//  
//
//  Created by Joel Saltzman on 5/23/21.
//

import Foundation


/// Mock a function and store it's usage history.
@propertyWrapper public final class Mock<Context, Value>: Mockable {

    
    /// Get direct access the underlying Mock object.
    public var projectedValue: Mock<Context, Value> { return self }
    
    /// Stores the input and output of the when the Mock gets a value.
    public var usage: MockUsage<Context, Value>
    
    /// The initial closure that the Mock was setup with.
    public var defaultValueLoader: (Context) -> Value {
        didSet {
            currentValueLoader = defaultValueLoader
        }
    }
    
    /// Use to the current value load to get an expected value.
    public var wrappedValue: (Context) -> Value {
        get {
            return getValue
        }
        set {
            currentValueLoader = newValue
        }
    }
    
    /// This will either be the `defaultValueLoader` from when you initialized the Mock.
    /// Or this will be a custom one for mocking expected values.
    var currentValueLoader: (Context) -> Value
    
    
    /// Initial the Mock with a default value loader.
    /// - Parameter wrappedValue: A closure to return a value. This is typically the live version of the function. You can override this later and reset back to this original value loader.
    public init(wrappedValue: @escaping (Context) -> Value) {
        self.usage = MockUsage()
        self.defaultValueLoader = wrappedValue
        self.currentValueLoader = wrappedValue
    }
    
    
    /// Get a value from the current value loader
    /// - Parameter context: The context required by the closure to get the value.
    /// - Returns: The value from the value loader.
    public func getValue(_ context: Context) -> Value {
        let result = currentValueLoader(context)
        usage.addResult(context: context, value: result)
        return result
    }
    
    /// Reset the value loader to the default one used when the Mock was created.
    public func resetLoader() {
        self.currentValueLoader = defaultValueLoader
    }
}
