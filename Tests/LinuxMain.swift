//
//  File.swift
//  
//
//  Created by Joel Saltzman on 5/23/21.
//

import XCTest
import MockingTests

var tests = [XCTestCaseEntry]()
tests += EquatableTupleTests.allTests()
tests += MockFileManagerTests.allTests()
tests += MockFileManagerTests.allTests()
XCTMain(tests)
