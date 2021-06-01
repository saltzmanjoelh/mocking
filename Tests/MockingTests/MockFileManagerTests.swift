import XCTest
@testable import Mocking

final class MockFileManagerTests: XCTestCase {
    
    enum TestError: Error {
        case expected
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
    func testContentsOfDirectoryAtUrl() throws {
        // Given the inputs and mocked result for a mock
        let url = URL(fileURLWithPath: "")
        let keys = [URLResourceKey]()
        let mask: FileManager.DirectoryEnumerationOptions = []
        let fileManager = MockFileManager()
        fileManager.contentsOfDirectoryAtUrl = { _ in return [URL(fileURLWithPath: "success")] }
        
        // When contentsOfDirectory is called
        let result = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: mask)
        
        // Then then mocked result should be returned
        XCTAssertEqual(result, [URL(fileURLWithPath: "success")])
        XCTAssertTrue(fileManager.$contentsOfDirectoryAtUrl.wasCalled)
    }
    func testContentsOfDirectoryAtPath() throws {
        // Given the inputs and mocked result for a mock
        let path = "/some/path"
        let fileManager = MockFileManager()
        fileManager.contentsOfDirectoryAtPath = { _ in return ["success"] }
        
        // When contentsOfDirectory is called
        let result = try fileManager.contentsOfDirectory(atPath: path)
        
        // Then then mocked result should be returned
        XCTAssertEqual(result, ["success"])
        XCTAssertTrue(fileManager.$contentsOfDirectoryAtPath.wasCalled)
    }
    
    func testCreateDirectory() throws {
        // Given the inputs and mocked result for a mock
        let url = URL(fileURLWithPath: "/tmp/sub")
        let intermediateDirectories = false
        let attributes = [FileAttributeKey.posixPermissions: 0o777]
        let fileManager = MockFileManager()
        fileManager.createDirectory = { _ in }
        
        // When createDirectory is called
        let _ = try fileManager.createDirectory(at: url,
                                                withIntermediateDirectories: intermediateDirectories,
                                                attributes: attributes)
        
        // Then then mocked result should be returned
        XCTAssertTrue(fileManager.$createDirectory.wasCalled)
    }
    
    func testMountedVolumeURLs() {
        // Given the inputs for the mock and a mocked response
        let propertyKeys: [URLResourceKey]? = [.addedToDirectoryDateKey]
        let options: FileManager.VolumeEnumerationOptions = .skipHiddenVolumes
        let expected = [URL(fileURLWithPath: "success")]
        let fileManager = MockFileManager()
        fileManager.mountedVolumeURLs = { _ in
            return expected
        }
        
        
        // When calling mountedVolumeURLs
        let result = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: propertyKeys,
                                                   options: options)
        
        // Then the mocked result should be returned
        XCTAssertEqual(result, expected)
    }
    
    public var allTests = [
        ("testFileExists", testFileExists),
        ("testRemoveItem", testRemoveItem),
        ("testCopyItem", testCopyItem),
        ("testContentsOfDirectoryAtUrl", testContentsOfDirectoryAtUrl),
        ("testContentsOfDirectoryAtPath", testContentsOfDirectoryAtPath),
        ("testCreateDirectory", testCreateDirectory),
        ("testMountedVolumeURLs", testMountedVolumeURLs),
    ]
}
