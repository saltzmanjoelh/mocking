import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(EquatableTupleTests.allTests),
            testCase(MockFileManagerTests.allTests),
            testCase(EquatableTupleTests.allTests),
        ]
    }
#endif
