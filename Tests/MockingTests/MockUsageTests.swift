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
        let result = try fileManager.$createDirectory.wasCalled(search: url)
        
        // Then it should return true
        XCTAssertTrue(result, "Searching by partial tuple should have returned true.")
    }
    
    public var allTests = [
        ("testSearchingForEquatableTupleUsage", testSearchingForEquatableTupleUsage),
    ]
}
