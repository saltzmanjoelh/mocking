import XCTest
@testable import Mocking

final class EquatableTupleTests: XCTestCase {
    
    enum TestError: Error {
        case expected
    }
    
    func testEquatableInitialization() throws {
        // Give some Codable inputs
        let url1 = URL(fileURLWithPath: "/one")
        let url2 = URL(fileURLWithPath: "/two")
        
        // When initializing EquatableTuple with the encoding: variant
        let tuple = try EquatableTuple(encoding: [url1, url2])
        
        // Then the urls can be properly decoded
        let result1: URL = try tuple.inputs[0].decode()
        let result2: URL = try tuple.inputs[1].decode()
        XCTAssertEqual(result1, url1)
        XCTAssertEqual(result2, url2)
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
    
    func testCodableInputDecodeDictionary() throws {
        // Given an encoded Dictionary
        let original = ["key1": "value1"]
        let encoded = try CodableInput(original)
        
        // When decoding
        let result: [String: String]? = try encoded.decode()
        
        // The the original value should be received
        XCTAssertEqual(result, original)
    }
    
    func testCodableInputDecodeNil() throws {
        // Given an encoded Dictionary
        let original: [String: String]? = nil
        let encoded = try CodableInput(original)
        
        // When decoding
        let result: [String: String]? = try encoded.decode()
        
        // The the original value should be received
        XCTAssertEqual(result, original)
    }
    
    func testCodableInputDecodeAny() throws {
        // Given an encoded Dictionary
        let original: [String: String] = ["key": "value"]
        let encoded = try CodableInput(original)
        
        // When decoding
        let result: Any? = try encoded.decode()
        
        // The the original value should be received
        XCTAssertTrue("\(result!)".contains("key"))
        XCTAssertTrue("\(result!)".contains("value"))
    }
    
    func testCodableInputDescriptionWithString() throws {
        let original: String = "value"
        
        let input = try CodableInput(original)
        
        XCTAssertEqual(input.description, "value")
    }
    func testCodableInputDescriptionWithOptional() throws {
        let original: String? = "value"
        
        let input = try CodableInput(original)
        
        XCTAssertEqual(input.description, "value")
    }
    func testCodableInputDescriptionWithNil() throws {
        let original: String? = nil
        
        let input = try CodableInput(original)
        
        XCTAssertEqual(input.description, "nil")
    }
    
    public var allTests = [
        ("testEquatableTuple_handlesErrors", testEquatableTuple_handlesErrors),
        ("testCodableInputDecode", testCodableInputDecode),
        ("testCodableInputDecodeDictionary", testCodableInputDecodeDictionary),
        ("testCodableInputDecodeNil", testCodableInputDecodeNil),
        ("testCodableInputDecodeAny", testCodableInputDecodeAny),
    ]
}
