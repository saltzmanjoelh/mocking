//
//  Mockable.swift
//
//
//  Created by Joel Saltzman on 5/18/21.
//

import Foundation


public protocol Mockable {
    
    /// Input context for the value loader
    associatedtype Context
    /// Output result value of the value loader
    associatedtype Value
    
    
    /// Keeps track of when a value is retrieved from a value loader.
    var usage: MockUsage<Context, Value> { get set }
    
    /// Direct access to the Mockable object
    var projectedValue: Self { get }
    
    /// Reset the value loader to the default one used when the Mock was created.
    func resetLoader()
}

extension Mockable {
    
    
    /// - Returns: True if a value retrieved from the value loader as least once. Otherwise, false is returned.
    public var wasCalled: Bool { usage.history.count > 0 }
}
