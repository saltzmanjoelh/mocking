//
//  MockUsage.swift
//  
//
//  Created by Joel Saltzman on 5/23/21.
//

import Foundation

public class MockUsage<Context, Value> {
    public class Entry {
        public var context: Context
        public var result: Result<Value, Error>
        public init(context: Context, result: Result<Value, Error>) {
            self.context = context
            self.result = result
        }
    }
    
    public var history = [Entry]()
    
    public func addResult(context: Context, value: Value) {
        history.append(Entry(context: context, result: .success(value)))
    }
    public func addError(context: Context, error: Error) {
        history.append(Entry(context: context, result: .failure(error)))
    }
}

/// This only works when the Context is Equatable. If you have more than one argument
/// for a Stub's Context, you can provide a tuple as the Context. However, a tuple cannot
/// conform to Equatable. If all the arguments are the same type, you can use EquatableTuple.
extension Mockable where Context: Equatable {

    public func wasCalled(with search: Context) -> Bool {
        return usage.history.first { entry in
            return entry.context == search
        } != nil
    }
    public func wasCalled<Value: Equatable>(with search: Value) -> Bool
    where Context == EquatableTuple<Value> {
        return usage.history.first(where:{ entry in // Iterate the history entries (context: EquatableTuples)
            entry.context.inputs.first(where: { entryInput in // Iterate the inputs (CodableInput)
                return entryInput == search // and compare against the data
            }) != nil
        }) != nil

    }
}

extension Mockable where Context == EquatableTuple<CodableInput> {
    public func wasCalled<Value: Codable>(with search: Value) throws -> Bool {
        return try usage.history.first(where:{ entry in // Iterate the history entries (cotext: EquatableTuples)
            try entry.context.inputs.first(where: { (codableInput: CodableInput) throws -> Bool in // Iterate the inputs (CodableInput)
                let inputData = try JSONEncoder().encode(search) // Encode the search
                return codableInput.data == inputData // and compare against the data
            }) != nil
        }) != nil
    }
}
