//
//  Mockable.swift
//
//
//  Created by Joel Saltzman on 5/18/21.
//

import Foundation

public protocol Mockable {
    associatedtype Context
    associatedtype Value
    var usage: MockUsage<Context, Value> { get set }
    var projectedValue: Self { get }
    func resetLoader()
}
