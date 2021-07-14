# mocking


[<img src="http://img.shields.io/badge/swift-5.3-brightgreen.svg" alt="Swift 5.3" />](https://swift.org)
[<img src="https://github.com/saltzmanjoelh/mocking/workflows/Swift/badge.svg" />](https://github.com/saltzmanjoelh/mocking/actions)
[<img src="https://codecov.io/gh/saltzmanjoelh/mocking/branch/main/graph/badge.svg" alt="Codecov Result" />](https://codecov.io/gh/saltzmanjoelh/mocking)

Simple property wrappers to help with mocks

## TLDR
Take a look at [MockFileManager](Sources/Mocking/MockTypes/MockFileManager.swift) for different examples. We create a protocol (`FileManageable`) that our subject which we want to mock (`FileManager`) can automatically conform to. We also create a mock version of that subject (`MockFileManager`) which conforms to the same protocol. We will now use the new protocol (`FileManageable`) for types instead of the original subject's type (`FileManager`). 

The mock object will get properties marked with `@Mock` or `@ThrowingMock`. These will simply be wrappers to the original subject (`FileManager`). You can override these with custom closures to return a desired result and check their usage.

You are basically building a wrapper class around the class that you want to mock. The the mocked functions in the wrapper class will perform the actual function by default but you can override this by setting the Mock closures to return a different response.

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
        return fileExistsMock(path) // Use our @Mock to perform the action and get the value
    }
    @Mock
    public var fileExistsMock = { path -> Bool in
        // Default implementation but you can override it.
        // When you are done, simply call fileManager.fileExists = fileManager.$fileExists.defaultValueLoader
        return FileManager.default.fileExists(atPath: path)
    }
}
```

## Projected value
The actual object Mock is available via the projected value dollar sign syntax. We use this for the usage history (described below) or exlicitly accessing the mock closure.

If you need to distinguish between the name of the mock and the name of the function, you can access the projected value:

```swift
public func fileExists(atPath path: String) -> Bool {
    return fileExists(path) // Use our @Mock to perform the action and get the value
}
```

You could always be explicit:

```swift
public func fileExists(atPath path: String) -> Bool {
    return $fileExists.getValue(path) // Use our @Mock to perform the action and get the value
}
@Mock
public var fileExistsMock = { path -> Bool in
    // Default implementation but you can override it.
    // When you are done, simply call fileManager.fileExists = fileManager.$fileExists.defaultValueLoader
    return FileManager.default.fileExists(atPath: path)
}
```

Or simply add "...Mock" at the end:

You don't have to add "...Mock" to the end of the variable name. I do it to disambiguate the function names. Otherwise, they would look infinitely recursive at first glance:

```swift
public func fileExists(atPath path: String) -> Bool {
    return fileExistsMock(path) // Use our @Mock to perform the action and get the value
}
@Mock
public var fileExistsMock = { path -> Bool in
    // Default implementation but you can override it.
    // When you are done, simply call fileManager.fileExists = fileManager.$fileExists.defaultValueLoader
    return FileManager.default.fileExists(atPath: path)
}
```

The `fileExists` function simply uses the  `@Mock` [property wrapper closure](Sources/Mocking/Mocks/Mock.swift) to perform an action and load a value. The property wrapper stores it's initial closure as the `defaultValueLoader`. Later, you can set it to use a custom closure. Typically, I create a new instance of the `MockFileManager` for every test so that I don't have to reset the custom closure back to default when I'm done. However, since the mock stores the original closure as default, you can simply call `fileManager.$fileExistsMock.resetLoader()` to reset it back to default. 

The dollar sign syntax calls the `projectedValue` property of the mock which simply returns itself. This gives you direct access to it's usage property `fileManager.$fileExistsMock.usage` if you need it. 

## Usage History

Continuing with our `fileExists` example, it requires a path for it's input. We call this a Context. When testing with mocks, sometimes we want to make sure that our mocked function was called with the expected Context.

Every mock keeps track of it's usage internally with the `MockUsage` class. When the mock's `getValue` [function](Sources/Mocking/Mocks/Mock.swift) is called, we perform a few steps:

* Get the value by calling the mock's current closure stored in it's `currentValueLoader` property.
* Create an entry in the usage history that contains both the input Context and the value we just received.
* Finally, return the value we just received.

If the Context conforms to Equatable, we have a helper function [wasCalled(with:)](Sources/Mocking/MockUsage.swift) that we can use with our assertion.

```swift
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
```

## Multiple Inputs

The `fileExists(atPath:)` example is simple because it's a single input. Things start to get slightly tricky when you start adding values to the Context. Take for example `copyItem(at srcURL: URL, to dstURL: URL) throws`.  You will need to use the `@ThrowingMock` [property wrapper](Sources/Mocking/Mocks/ThrowingMock.swift) since this function throws. The wrapped value takes a closure with a single Context `(Context) throws -> Value`. However, `copyItem(at:to:)` needs multiple arguments, a source and destination. My first attempt at solution is to create a tuple for this:  `((src: mySrcURL, dstURL: myDestURL)) throws -> Void)`. You can use the tuple, but this prevents us from using the `wasCalled(with:)` helper because `wasCalled(with:)` requires that the Context is Equatable and tuples cannot confrom to Equatable. You end up with assertion code that looks something like this:

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
    try copyItemMock(EquatableTuple([srcURL, dstURL]))
}
@ThrowingMock
public var copyItemMock = { (tuple: EquatableTuple) throws in
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
    return try $contentsOfDirectoryAtUrlMock.getValue(context)
}
@ThrowingMock
public var contentsOfDirectoryAtUrlMock = { (tuple: EquatableTuple<CodableInput>) throws in
    return try FileManager.default.contentsOfDirectory(at: try tuple.inputs[0].decode(),
                                                       includingPropertiesForKeys: try tuple.inputs[1].decode(),
                                                       options: try tuple.inputs[2].decode())
}
```
