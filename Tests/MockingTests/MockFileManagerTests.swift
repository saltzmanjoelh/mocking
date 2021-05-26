import XCTest
@testable import Mocking

final class MockFileManagerTests: XCTestCase {
    
    enum TestError: Error {
        case expected
    }
    
    func testResetLoader() {
        // Given a mock that has been reset
        let fileManager = MockFileManager()
        fileManager.fileExists = { _ in return true }
        fileManager.fileExists = fileManager.$fileExists.defaultValueLoader
        
        // When calling the mock
        let result = fileManager.fileExists(atPath: "invalid")
        
        // Then the default valueLoad
        XCTAssertFalse(result, "False should have been returned for the \"invalid\" path.")
        XCTAssertTrue(fileManager.$fileExists.wasCalled, "The mock value loader should have been called.")
    }
    func testDefaultValueLoader() {
        // Given a mock that has not been customized
        let fileManager = MockFileManager()
        
        // When calling the mock
        let result = fileManager.fileExists(atPath: "/tmp")
        
        // Then the default value loader should be called
        XCTAssertTrue(result, "True should have been returned")
    }
    func testFileExists() {
        // Given a mocked function
        let path = "Mocking 💪"
        let fileManager = MockFileManager()
        fileManager.fileExists = { path in
            return true
        }
        
        // When calling the function
        // Then it should return the fixed response
        XCTAssertTrue(fileManager.fileExists(atPath: path))
        // and it should be marked as having been called
        XCTAssertTrue(fileManager.$fileExists.wasCalled(with: path))
        XCTAssertTrue(fileManager.$fileExists.wasCalled)
    }
    func testRemoveItem() {
        // Given a mock that throws
        let fileManager = MockFileManager()
        fileManager.removeItem = { path in
            throw TestError.expected
        }
        
        // When calling the mock with a single
        // Then it should throw the error
        XCTAssertThrowsError(try fileManager.removeItem(at: URL(fileURLWithPath: "any")))
        XCTAssertTrue(fileManager.$removeItem.wasCalled)
    }
    func testCopyItem() throws {
        // Given a mock that requires an EquatableTuple
        let source = URL(fileURLWithPath: "source")
        let destination = URL(fileURLWithPath: "destination")
        let fileManager = MockFileManager()
        fileManager.copyItem = { _ in }
        
        // When calling the mock that encodes inputs to EquatableTuple
        try fileManager.copyItem(at: source, to: destination)
        
        // Then it should it should store it in the history
        XCTAssertTrue(fileManager.$copyItem.wasCalled(with: .init([source, destination])))
    }
    func testCopyItem_defaultValueLoader() throws {
        // Given a mock that requires an EquatableTuple
        let source = URL(fileURLWithPath: "source")
        let destination = URL(fileURLWithPath: "destination")
        let fileManager = MockFileManager()
        
        // When calling the mock that encodes inputs to EquatableTuple
        XCTAssertThrowsError(try fileManager.copyItem(at: source, to: destination))
        
        // Then it should it should store it in the history
        XCTAssertTrue(fileManager.$copyItem.wasCalled(with: .init([source, destination])))
    }
    func testContentsOfDirectory() throws {
        // Give the inputs for a mock
        let url = URL(fileURLWithPath: "")
        let keys = [URLResourceKey]()
        let mask: FileManager.DirectoryEnumerationOptions = []
        let fileManager = MockFileManager()
        fileManager.contentsOfDirectory = { _ in return [URL(fileURLWithPath: "success")] }
        
        // When contentsOfDirectory is called
        let result = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: mask)
        
        // Then it should be called without throwing
        XCTAssertEqual(result, [URL(fileURLWithPath: "success")])
        XCTAssertTrue(fileManager.$contentsOfDirectory.wasCalled)
    }
    func testContentsOfDirectory_defaultValueLoader() throws {
        // Give the inputs for a mock
        let url = URL(fileURLWithPath: "/tmp")
        let keys = [URLResourceKey]()
        let mask: FileManager.DirectoryEnumerationOptions = []
        let fileManager = MockFileManager()
        
        // When contentsOfDirectory is called
        let _ = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: mask)
        
        // Then it should be called without throwing
        XCTAssertTrue(fileManager.$contentsOfDirectory.wasCalled)
    }
    
    public var allTests = [
        ("testResetLoader", testResetLoader),
        ("testDefaultValueLoader", testDefaultValueLoader),
        ("testFileExists", testFileExists),
        ("testRemoveItem", testRemoveItem),
        ("testCopyItem", testCopyItem),
        ("testContentsOfDirectory", testContentsOfDirectory),
        ("testContentsOfDirectory_defaultValueLoader", testContentsOfDirectory_defaultValueLoader)
    ]
}
