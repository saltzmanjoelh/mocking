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
        fileManager.fileExistsMock = { path in
            return true
        }
        
        // When calling the function
        // Then it should return the fixed response
        XCTAssertTrue(fileManager.fileExists(atPath: path))
        // and it should be marked as having been called
        XCTAssertTrue(fileManager.$fileExistsMock.wasCalled(with: path))
        XCTAssertTrue(fileManager.$fileExistsMock.wasCalled)
    }
    func testRemoveItem() {
        // Given a mock that throws
        let fileManager = MockFileManager()
        fileManager.removeItemMock = { path in
            throw TestError.expected
        }
        
        // When calling the mock with a single
        // Then it should throw the error
        XCTAssertThrowsError(try fileManager.removeItem(at: URL(fileURLWithPath: "any")))
        XCTAssertTrue(fileManager.$removeItemMock.wasCalled)
    }
    func testCopyItem() throws {
        // Given a mock that requires an EquatableTuple
        let source = URL(fileURLWithPath: "source")
        let destination = URL(fileURLWithPath: "destination")
        let fileManager = MockFileManager()
        fileManager.copyItemMock = { _ in }
        
        // When calling the mock that encodes inputs to EquatableTuple
        try fileManager.copyItem(at: source, to: destination)
        
        // Then it should it should store it in the history
        XCTAssertTrue(fileManager.$copyItemMock.wasCalled(with: .init([source, destination])))
    }
    func testContentsOfDirectoryAtUrl() throws {
        // Given the inputs and mocked result for a mock
        let url = URL(fileURLWithPath: "")
        let keys = [URLResourceKey]()
        let mask: FileManager.DirectoryEnumerationOptions = []
        let fileManager = MockFileManager()
        fileManager.contentsOfDirectoryAtUrlMock = { _ in return [URL(fileURLWithPath: "success")] }
        
        // When contentsOfDirectory is called
        let result = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: mask)
        
        // Then then mocked result should be returned
        XCTAssertEqual(result, [URL(fileURLWithPath: "success")])
        XCTAssertTrue(fileManager.$contentsOfDirectoryAtUrlMock.wasCalled)
    }
    func testContentsOfDirectoryAtPath() throws {
        // Given the inputs and mocked result for a mock
        let path = "/some/path"
        let fileManager = MockFileManager()
        fileManager.contentsOfDirectoryAtPathMock = { _ in return ["success"] }
        
        // When contentsOfDirectory is called
        let result = try fileManager.contentsOfDirectory(atPath: path)
        
        // Then then mocked result should be returned
        XCTAssertEqual(result, ["success"])
        XCTAssertTrue(fileManager.$contentsOfDirectoryAtPathMock.wasCalled)
    }
    func testContentsAtPath() throws {
        // Given a path
        let path = "/some/path"
        let expected = "expected".data(using: .utf8)
        let fileManager = MockFileManager()
        fileManager.contentsAtPathMock = { _ in return expected }
        
        // When calling contents(at:)
        let result = fileManager.contents(atPath: path)
        
        // Then the mocked data is returned
        XCTAssertEqual(result, expected)
    }
    
    func testCreateDirectory() throws {
        // Given the inputs and mocked result for a mock
        let url = URL(fileURLWithPath: "/tmp/sub")
        let intermediateDirectories = false
        let attributes = [FileAttributeKey.posixPermissions: 0o777]
        let fileManager = MockFileManager()
        fileManager.createDirectoryMock = { _ in }
        
        // When createDirectory is called
        let _ = try fileManager.createDirectory(at: url,
                                                withIntermediateDirectories: intermediateDirectories,
                                                attributes: attributes)
        
        // Then then mocked result should be returned
        XCTAssertTrue(fileManager.$createDirectoryMock.wasCalled)
    }
    func testCreateDirectory_withEmptyAttributes() throws {
        // Given the inputs and mocked result for a mock
        let url = URL(fileURLWithPath: "/tmp/sub")
        let intermediateDirectories = false
        let attributes: [FileAttributeKey: Any] = [:]
        let fileManager = MockFileManager()
        fileManager.createDirectoryMock = { _ in }
        
        // When createDirectory is called
        let _ = try fileManager.createDirectory(at: url,
                                                withIntermediateDirectories: intermediateDirectories,
                                                attributes: attributes)
        
        // Then then mocked result should be returned
        XCTAssertTrue(fileManager.$createDirectoryMock.wasCalled)
    }
    func testCreateDirectory_withNilAttributes() throws {
        // Given the inputs and mocked result for a mock
        let url = URL(fileURLWithPath: "/tmp/sub")
        let intermediateDirectories = false
        let attributes: [FileAttributeKey: Any]? = nil
        let fileManager = MockFileManager()
        fileManager.createDirectoryMock = { _ in }
        
        // When createDirectory is called
        let _ = try fileManager.createDirectory(at: url,
                                                withIntermediateDirectories: intermediateDirectories,
                                                attributes: attributes)
        
        // Then then mocked result should be returned
        XCTAssertTrue(fileManager.$createDirectoryMock.wasCalled)
    }
    
    func testMountedVolumeURLs() {
        // Given the inputs for the mock and a mocked response
        let propertyKeys: [URLResourceKey]? = [.addedToDirectoryDateKey]
        let options: FileManager.VolumeEnumerationOptions = .skipHiddenVolumes
        let expected = [URL(fileURLWithPath: "success")]
        let fileManager = MockFileManager()
        fileManager.mountedVolumeURLsMock = { _ in
            return expected
        }
        
        
        // When calling mountedVolumeURLs
        let result = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: propertyKeys,
                                                   options: options)
        
        // Then the mocked result should be returned
        XCTAssertEqual(result, expected)
    }
    
    func testChangeCurrentDirectoryPath() {
        // Given an invalid path and a stubbed response
        let path = "/\(UUID().uuidString)"
        let fileManager = MockFileManager()
        fileManager.changeCurrentDirectoryPathMock = { _ in
            return true
        }
        
        // When calling changeCurrentDirectoryPath
        let result = fileManager.changeCurrentDirectoryPath(path)
        
        // Then true should be returned
        XCTAssertTrue(result)
    }
    
    func testCurrentDirectoryPath() {
        // Given an path
        let path = "/\(UUID().uuidString)"
        let fileManager = MockFileManager()
        fileManager.currentDirectoryPathMock = { _ in
            return path
        }

        // When calling currentDirectory
        let result = fileManager.currentDirectoryPath

        // Then the path should be returned
        XCTAssertEqual(result, path)
    }
    func testUsersHomeDirectory() {
        // Given an path
        let dir = URL(fileURLWithPath:"/\(UUID().uuidString)")
        let fileManager = MockFileManager()
        fileManager.usersHomeDirectoryMock = { _ in
            return dir
        }

        // When calling homeDirectoryForCurrentUser
        let result = fileManager.usersHomeDirectory

        // Then the path should be returned
        XCTAssertEqual(result, dir)
    }
    func testUsersHomeDirectoryDefaultValue() {
        // Given the default home path
        let dir = URL(fileURLWithPath: NSHomeDirectory())
        let fileManager = MockFileManager()

        // When calling homeDirectoryForCurrentUser
        let result = fileManager.usersHomeDirectory

        // Then the path should be returned
        XCTAssertEqual(result, dir)
    }
    
    public var allTests = [
        ("testFileExists", testFileExists),
        ("testRemoveItem", testRemoveItem),
        ("testCopyItem", testCopyItem),
        ("testContentsOfDirectoryAtUrl", testContentsOfDirectoryAtUrl),
        ("testContentsOfDirectoryAtPath", testContentsOfDirectoryAtPath),
        ("testContentsAtPath", testContentsAtPath),
        ("testCreateDirectory", testCreateDirectory),
        ("testMountedVolumeURLs", testMountedVolumeURLs),
        ("testChangeCurrentDirectoryPath", testChangeCurrentDirectoryPath),
        ("testCurrentDirectoryPath", testCurrentDirectoryPath),
        ("testUsersHomeDirectory", testUsersHomeDirectory),
        ("testUsersHomeDirectoryDefaultValue", testUsersHomeDirectoryDefaultValue),
    ]
}
