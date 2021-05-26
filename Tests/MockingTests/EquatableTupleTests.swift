import XCTest
@testable import Mocking

final class EquatableTupleTests: XCTestCase {
    
    enum TestError: Error {
        case expected
    }
    
    func testEquatableTuple_handlesErrors() throws {
        // Given a mock that throws
        let fileManager = MockFileManager()
        fileManager.copyItem = { _ in throw TestError.expected }
        
        // When calling the mock
        // Then it should throw
        XCTAssertThrowsError(try fileManager.copyItem(at: URL(fileURLWithPath: ""), to: URL(fileURLWithPath: "")))
        XCTAssertTrue(fileManager.$copyItem.wasCalled)
    }
    
    
    public var allTests = [
        ("testEquatableTuple_handlesErrors", testEquatableTuple_handlesErrors),
    ]
}
