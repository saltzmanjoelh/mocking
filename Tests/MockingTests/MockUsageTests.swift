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
        let result = try fileManager.$createDirectory.wasCalled(with: url)
        
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
    
    public var allTests = [
        ("testSearchingForEquatableTupleUsage", testSearchingForEquatableTupleUsage),
    ]
}
