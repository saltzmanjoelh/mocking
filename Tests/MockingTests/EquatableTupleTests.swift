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
    
    func testCodableInputDecodeAny() throws {
        // Given an encoded Dictionary
        let original = ["key1": "value1"]
        let encoded = try CodableInput(original)
        
        // When decoding
        let decoded: Any = try encoded.decode()
        
        // The the original value should be received
        let result = decoded as? [String: String]
        XCTAssertEqual(result, original)
    }
    
    public var allTests = [
        ("testEquatableTuple_handlesErrors", testEquatableTuple_handlesErrors),
        ("testCodableInputDecode", testCodableInputDecode),
        ("testCodableInputDecodeAny", testCodableInputDecodeAny),
    ]
}
