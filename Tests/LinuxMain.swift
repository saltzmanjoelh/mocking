//
//  File.swift
//  
//
//  Created by Joel Saltzman on 5/23/21.
//

import XCTest
import MockingTests

var tests = [XCTestCaseEntry]()
tests += MockFileManagerTests.allTests()
XCTMain(tests)
