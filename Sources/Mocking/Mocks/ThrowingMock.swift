//
//  ThrowingMock.swift
//  
//
//  Created by Joel Saltzman on 5/23/21.
//

import Foundation

@propertyWrapper struct ThrowingMock<Context, Value>: Mockable {

    public var usage: MockUsage<Context, Value>
    public var wrappedValue: (Context) throws -> Value
    public var defaultValueLoader: (Context) throws -> Value
    public var projectedValue: ThrowingMock<Context, Value> { return self }
    
    public init(wrappedValue: @escaping (Context) throws -> Value) {
        self.usage = MockUsage()
        self.wrappedValue = wrappedValue
        self.defaultValueLoader = wrappedValue
    }
    
    public mutating func getValue(_ context: Context) throws -> Value {
        let result: Value
        do {
            result = try wrappedValue(context)
            usage.addResult(context: context, value: result)
        } catch {
            usage.addError(context: context, error: error)
            throw error
        }
        return result
    }
    
//    public mutating func resetLoader() {
//        self.wrappedValue = defaultValueLoader
//    }
}
