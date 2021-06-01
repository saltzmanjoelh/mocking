//
//  Mock.swift
//  
//
//  Created by Joel Saltzman on 5/23/21.
//

import Foundation

@propertyWrapper public final class Mock<Context, Value>: Mockable {

    public var usage: MockUsage<Context, Value>
    public var defaultValueLoader: (Context) -> Value
    public var wrappedValue: (Context) -> Value
    public var projectedValue: Mock<Context, Value> { return self }
    
    public init(wrappedValue: @escaping (Context) -> Value) {
        self.usage = MockUsage()
        self.defaultValueLoader = wrappedValue
        self.wrappedValue = wrappedValue
    }
    
    // We can't use dynamic get/set in var wrappedValue because
    // we need to provide the context.
    public func getValue(_ context: Context) -> Value {
        let result = wrappedValue(context)
        usage.addResult(context: context, value: result)
        return result
    }
    
    // Reset the closure to the default one used when the mock
    // was created.
    public func resetLoader() {
        self.wrappedValue = defaultValueLoader
    }
}
