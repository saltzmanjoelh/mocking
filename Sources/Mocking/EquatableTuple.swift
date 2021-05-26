//
//  EquatableTuple.swift
//  
//
//  Created by Joel Saltzman on 5/24/21.
//

import Foundation


/// A helper struct for when you have the same types of inputs of a Context.
/// If your inputs of a Context have different types, you can use a CodableTuple.
/// We want Equatable inputs so that we can use the `wasCalled` helpers.
public struct EquatableTuple<Input: Equatable>: Equatable {
    public let inputs: [Input]
    public init(_ inputs: [Input]) {
        self.inputs = inputs
    }
}

/// When the inputs of a Context have different types, you can use CodableTuple to encode each input.
/// When the mock tries to call getValue() it can decode the Inputs and use their values.
/// We want Equatable inputs so that we can use the `wasCalled` helpers.
public struct CodableInput: Equatable {
    /// The encoded data of the represented Value
    let data: Data
    
    public init<Value: Codable>(_ rawValue: Value) throws {
        self.data = try JSONEncoder().encode(rawValue)
    }
    public func decode<Value: Codable>() throws -> Value {
        return try JSONDecoder().decode(Value.self, from: data)
    }
}
