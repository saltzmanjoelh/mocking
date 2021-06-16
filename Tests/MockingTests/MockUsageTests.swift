import XCTest
@testable import Mocking

final class MockUsageTests: XCTestCase {
    
    func testSearchingForEquatableTupleUsage() throws {
        // Given a mock that was called with EquatableTuple
        let fileManager = MockFileManager()
        fileManager.createDirectory = { _ in }
        let url = URL(fileURLWithPath: "/tmp/sub")
        let intermediateDirectories = false
        let attributes = [FileAttributeKey.posixPermissions: 0o777]
        let _ = try fileManager.createDirectory(at: url,
                                                withIntermediateDirectories: intermediateDirectories,
                                                attributes: attributes)
        
        // When calling wasCalled with one of it's inputs
        let result = fileManager.$createDirectory.wasCalled(with: url)
        
        // Then it should return true
        XCTAssertTrue(result, "Searching by partial tuple should have returned true.")
    }
    func testSearchingForEquatableTupleUsage_copyItem() throws {
        // Given a mock that was called with EquatableTuple
        let fileManager = MockFileManager()
        fileManager.copyItem = { _ in }
        let source = URL(fileURLWithPath: "/tmp/source")
        let destination = URL(fileURLWithPath: "/tmp/dest")
        let _ = try fileManager.copyItem(at: source, to: destination)
        
        // When calling wasCalled with one of it's inputs
        let result = fileManager.$copyItem.wasCalled(with: source)
        
        // Then it should return true
        XCTAssertTrue(result, "Searching by partial tuple should have returned true.")
    }
    
    func testContexts() throws {
        // Given a mock that was called
        let url = URL(fileURLWithPath: "/source")
        let keys: [URLResourceKey]? = nil
        let options: FileManager.DirectoryEnumerationOptions = []
        let fileManager = MockFileManager()
        fileManager.copyItem = { _ in }
        fileManager.contentsOfDirectoryAtUrl = { _ in return [] }
        _ = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: options)

        // When calling contexts
        let result = fileManager.$contentsOfDirectoryAtUrl.usage.contexts
        
        // Then the input contexts should be returned
        let expected: EquatableTuple<CodableInput> = .init([try CodableInput(url), try CodableInput(keys), try CodableInput(options)])
        XCTAssertEqual(result, [expected])
    }
    func testInputDescriptions() throws {
        // Given a mock that was called
        let url = URL(fileURLWithPath: "/source")
        let keys: [URLResourceKey]? = nil
        let options: FileManager.DirectoryEnumerationOptions = []
        let fileManager = MockFileManager()
        fileManager.copyItem = { _ in }
        fileManager.contentsOfDirectoryAtUrl = { _ in return [] }
        _ = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: options)

        // When calling contexts
        let result = fileManager.$contentsOfDirectoryAtUrl.usage.inputDescriptions
        
        // Then the input contexts should be returned
        XCTAssertEqual(result, [[String(describing: url), String(describing: keys), String(describing: options)]])
    }
    
//    func testWasCalledWithErrorHandling() throws {
//        // Testing wasCalledWith<Value: Codable>(_ search: Value)
//        // throws when the search is not found
//        // Given a mock that was called
//        let source = URL(fileURLWithPath: "/source")
//        let fileManager = MockFileManager()
//        fileManager.copyItem = { _ in }
//        fileManager.contentsOfDirectoryAtUrl = { _ in return [] }
//        _ = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "/unexpected_url"), includingPropertiesForKeys: nil)
//
//        do {
//            // When calling wasCalledWith
//            try fileManager.$contentsOfDirectoryAtUrl.wasCalledWith(source)
//
//            XCTFail("An error should have been thrown.")
//        } catch {
//            XCTAssertEqual("\(error)", MockUsageError.notFound("\(source)", [URL(fileURLWithPath: "/unexpected_url")]).description)
//        }
//    }
//    func testWasCalledWithDoesNotThrowWithValidSearch() throws {
//        // Testing wasCalledWith<Value: Codable>(_ search: Value)
//        // throws when the search is not found
//        // Given a mock that was called
//        let source = URL(fileURLWithPath: "/source")
//        let fileManager = MockFileManager()
//        fileManager.copyItem = { _ in }
//        fileManager.contentsOfDirectoryAtUrl = { _ in return [] }
//        _ = try fileManager.contentsOfDirectory(at: source, includingPropertiesForKeys: nil)
//        
//        // When calling wasCalledWith
//        // Then no error should be thrown
//        XCTAssertNoThrow(try fileManager.$contentsOfDirectoryAtUrl.wasCalledWith(source))
//    }
    
    public var allTests = [
        ("testSearchingForEquatableTupleUsage", testSearchingForEquatableTupleUsage),
        ("testSearchingForEquatableTupleUsage", testSearchingForEquatableTupleUsage),
    ]
}
