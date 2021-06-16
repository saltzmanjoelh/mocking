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
extension EquatableTuple where Input == CodableInput {
    public init<RawType: Codable>(encoding rawValues: [RawType]) throws {
        self.inputs = try rawValues.map({ try CodableInput($0) })
    }
}

/// When the inputs of a Context have different types, you can use CodableTuple to encode each input.
/// When the mock tries to call getValue() it can decode the Inputs and use their values.
/// We want Equatable inputs so that we can use the `wasCalled` helpers.
public struct CodableInput: Equatable, Codable {
    /// The encoded data of the represented Value
    public let data: Data
    public let description: String
    
    public init<Value: Codable>(_ rawValue: Value) throws {
        self.data = try JSONEncoder().encode(rawValue)
        self.description = String(describing: rawValue)
    }
    public init<Value: Any>(anyValue rawValue: Value?) throws {
        if let value = rawValue {
            self.data = try JSONSerialization.data(withJSONObject: value as Any, options: [])
            self.description = String(describing: value)
        } else {
            self.data = Data()
            self.description = "nil"
        }
    }
    public func decode<Value: Codable>() throws -> Value {
        return try JSONDecoder().decode(Value.self, from: data)
    }
    public func decode<Value: Any>() throws -> Value? {
        guard data.count >= 0 else { return nil }
        return try JSONSerialization.jsonObject(with: data, options: []) as? Value
    }
}
