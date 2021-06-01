# mocking


[<img src="http://img.shields.io/badge/swift-5.3-brightgreen.svg" alt="Swift 5.3" />](https://swift.org)
[<img src="https://github.com/saltzmanjoelh/mocking/workflows/Swift/badge.svg" />](https://github.com/saltzmanjoelh/mocking/actions)
[<img src="https://codecov.io/gh/saltzmanjoelh/mocking/branch/main/graph/badge.svg" alt="Codecov Result" />](https://codecov.io/gh/saltzmanjoelh/mocking)

Simple property wrappers to help with mocks

## TLDR
Take a look at [MockFileManager](Sources/Mocking/MockTypes/MockFileManager.swift) for different examples.

## Usage

Let's use `FileManager` as our example. Let's say we want to mock the `fileExists(atPath path: String) -> Bool` function. Create a protocol that `FileManager` can automatically conform to:

```swift
public protocol FileManageable {
    func fileExists(atPath path: String) -> Bool
}

extension FileManager: FileManageable { }
```

Next, create your mock class that conforms to `FileManageable`. 

```swift
public class MockFileManager: NSObject, FileManageable {
    public func fileExists(atPath path: String) -> Bool {
        // TODO next, it's not buildable yet
    }
}
```

What do we want our mock function to do? We have two requirements.

* We want to support some default behavior so that we don't have to always mock a function.
* We also want to be able to override this default behavior with a closure to perform an expected behavior.

To do this we have the `@Mock` [property wrapper](Sources/Mocking/Mocks/Mock.swift).

```swift
public class MockFileManager: NSObject, FileManageable {
    public func fileExists(atPath path: String) -> Bool {
        return _fileExists.getValue(path) // Use our @Mock to perform the action and get the value
    }
    @Mock
    public var fileExists = { path -> Bool in
        // Default implementation but you can override it.
        // When you are done, simply call fileManager.fileExists = fileManager.$fileExists.defaultValueLoader
        return FileManager.default.fileExists(atPath: path)
    }
}
```

The `fileExists` function simply uses the  `@Mock` [property wrapper](Sources/Mocking/Mocks/Mock.swift) to perform an action and load a value. The property wrapper stores it's initial closure as the `defaultValueLoader`. Later, you can set it to use a custom closure. Typically, I create a new instance of the `MockFileManager` for every test so that I don't have to reset the custom closure back to default when I'm done. However, since the mock stores the original closure as default, you can simply call `fileManager.$fileExists.resetLoader()` to reset it back to default. 

The dollar sign syntax calls the `projectedValue` property of the mock which simply returns itself. This gives you direct access to it's usage property `fileManager.$fileExists.usage` if you need it. 

## Usage History

Continuing with our `fileExists` example, it requires a path for it's input. We call this a Context. When testing with mocks, sometimes we want to make sure that our mocked function was called with the expected Context.

Every mock keeps track of it's usage internally with the `MockUsage` class. When the mock's `getValue` [function](Sources/Mocking/Mocks/Mock.swift) is called, we perform a few steps:

* Get the value by calling the mock's current closure stored in it's `wrappedValue` property.
* Create an entry in the usage history that contains both the input Context and the value we just received.
* Finally, return the value we just received.

If the Context conforms to Equatable, we have a helper function [wasCalled(with:)](Sources/Mocking/MockUsage.swift) that we can use with our assertion.

```swift
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
```

## Multiple Inputs

The `fileExists(atPath:)` example is simple because it's a single input. Things start to get slightly tricky when you start adding values to the Context. Take for example `copyItem(at srcURL: URL, to dstURL: URL) throws`.  You will need to use the `@ThrowingMock` [property wrapper](Sources/Mocking/Mocks/ThrowingMock.swift) since this function throws. The wrapped value takes a closure with a single Context `(Context) throws -> Value`. However, `copyItem(at:to:)` needs a source and destination. My first attempt ata solution is to create a tuple for this:  `((src: mySrcURL, dstURL: myDestURL)) throws -> Void)`. You can use the tuple, but this prevents us from using the `wasCalled` helper because `wasCalled` requires that the Context is Equatable and tuples cannot confrom to Equatable. You end up with assertion code that looks something like this:

```swift
XCTAssertTrue(fileManager.$copyItem.usage.history.contains(where: { entry in
    return entry.context.0 == source,
    entry.context.1 == destination
}))
```

It's doable, but we can do better. 

### Homogeneous Inputs

Instead of using Swift's built-in tuple, let's use [EquatableTuple](Sources/Mocking/EquatableTuple.swift). If the Context has a homogeneous list of values, simply initialize it with an array of your function's inputs.

```swift
public func copyItem(at srcURL: URL, to dstURL: URL) throws {
    try _copyItem.getValue(EquatableTuple([srcURL, dstURL]))
}
@ThrowingMock
public var copyItem = { (tuple: EquatableTuple) throws in
    try FileManager.default.copyItem(at: tuple.inputs[0], to: tuple.inputs[1])
}
```

### Heterogeneous Inputs

Another common case is a function that uses different types of inputs. There are only two steps:

* Make sure that your types conform to Codable
* Wrap them in `CodableInput`

```swift
extension URLResourceKey: Codable { }
extension FileManager.DirectoryEnumerationOptions: Codable { }

public func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions = []) throws -> [URL] {
    let context = EquatableTuple([try CodableInput(url),
                                  try CodableInput(keys),
                                  try CodableInput(mask)])
    return try _contentsOfDirectoryAtUrl.getValue(context)
}
@ThrowingMock
public var contentsOfDirectoryAtUrl = { (tuple: EquatableTuple<CodableInput>) throws in
    return try FileManager.default.contentsOfDirectory(at: try tuple.inputs[0].decode(),
                                                       includingPropertiesForKeys: try tuple.inputs[1].decode(),
                                                       options: try tuple.inputs[2].decode())
}
```
