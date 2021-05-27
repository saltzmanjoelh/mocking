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
    func testCodableInputDecode() throws {
        // Given an encoded Codable
        let url = URL(fileURLWithPath: "/tmp")
        let encoded = try CodableInput(url)
        
        // When decoding
        let result: URL = try encoded.decode()
        
        // The the original value should be received
        XCTAssertEqual(url, result)
    }
    
    public var allTests = [
        ("testEquatableTuple_handlesErrors", testEquatableTuple_handlesErrors),
        ("testCodableInputDecode", testCodableInputDecode),
    ]
}
