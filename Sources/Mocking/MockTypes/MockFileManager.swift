//
//  MockFileManager.swift
//  
//
//  Created by Joel Saltzman on 5/23/21.
//

import Foundation

public protocol FileManageable {
    var currentDirectoryPath: String { get }
    
    func fileExists(atPath path: String) -> Bool
    func removeItem(at URL: URL) throws
    func copyItem(at srcURL: URL, to dstURL: URL) throws
    func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions) throws -> [URL]
    func contentsOfDirectory(atPath path: String) throws -> [String]
    func contents(atPath path: String) -> Data?
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws
    func mountedVolumeURLs(includingResourceValuesForKeys propertyKeys: [URLResourceKey]?, options: FileManager.VolumeEnumerationOptions) -> [URL]?
}
extension FileManager: FileManageable { }

public class MockFileManager: NSObject, FileManageable {
    
    // MARK: Single input
    public func fileExists(atPath path: String) -> Bool {
        return $fileExists.getValue(path)
    }
    @Mock
    public var fileExists = { path -> Bool in
        // Default implementation but you can override it.
        // When you are done, simply call fileManager.fileExists = fileManager.$fileExists.defaultValueLoader
        return FileManager.default.fileExists(atPath: path)
    }
    
    // MARK: Single input, throwing
    public func removeItem(at URL: URL) throws {
        try $removeItem.getValue(URL)
    }
    @ThrowingMock
    public var removeItem = { URL in
        // Default implementation but you can override it.
        // When you are done, simply call fileManager.removeItem = fileManager.$removeItem.defaultValueLoader
        try FileManager.default.removeItem(at: URL)
    }
    
    // MARK: Multiple inputs of the same type, throwing
    public func copyItem(at srcURL: URL, to dstURL: URL) throws {
        try $copyItem.getValue(EquatableTuple([srcURL, dstURL]))
    }
    @ThrowingMock
    public var copyItem = { (tuple: EquatableTuple<URL>) throws in
        // Default implementation but you can override it.
        // When you are done, simply call fileManager.copyItem = fileManager.$copyItem.defaultValueLoader
        try FileManager.default.copyItem(at: tuple.inputs[0], to: tuple.inputs[1])
    }
    
    // MARK: Multiple inputs with different types, throwing
    /// We package up the inputs into a single Equatable type so that we can use the `wasCalled(with:)` helper
    /// You don't have to do this, you can use a regular tuple but it doesn't conform to `Equatable` so
    /// you can't take advantage of the `wasCalled(with:)` helper.
    /// - Without EquatableTuple:
    /// ```swift
    /// public func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions = []) throws -> [URL] {
    ///     return try $contentsOfDirectory.getValue((url, keys, mask))
    /// }
    /// @ThrowingStub public var contentsOfDirectory = { (tuple: (url: URL, keys: [URLResourceKey]?, mask: FileManager.DirectoryEnumerationOptions)) throws in
    /// return try FileManager.default.contentsOfDirectory(at: tuple.url,
    ///                                                    includingPropertiesForKeys: tuple.keys,
    ///                                                    options: tuple.mask)
    /// ```
    public func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions = []) throws -> [URL] {
        let context = EquatableTuple([try CodableInput(url),
                                      try CodableInput(keys),
                                      try CodableInput(mask)])
        return try $contentsOfDirectoryAtUrl.getValue(context)
    }
    @ThrowingMock
    public var contentsOfDirectoryAtUrl = { (tuple: EquatableTuple<CodableInput>) throws in
        return try FileManager.default.contentsOfDirectory(at: try tuple.inputs[0].decode(),
                                                           includingPropertiesForKeys: try tuple.inputs[1].decode(),
                                                           options: try tuple.inputs[2].decode())
    }
    
    
    public func contentsOfDirectory(atPath path: String) throws -> [String] {
        return try $contentsOfDirectoryAtPath.getValue(path)
    }
    @ThrowingMock
    public var contentsOfDirectoryAtPath = { (path: String) throws in
        return try FileManager.default.contentsOfDirectory(atPath: path)
    }
    
    public func contents(atPath path: String) -> Data? {
        return $contentsAtPath.getValue(path)
    }
    @Mock
    public var contentsAtPath = { path -> Data? in
        return FileManager.default.contents(atPath: path)
    }
    
    public func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        let codedUrl = try CodableInput(url)
        let codedCreateIntermediates = try CodableInput(createIntermediates)
        let codedAttributes = try CodableInput(anyValue: attributes)
        return try $createDirectory.getValue(EquatableTuple([codedUrl, codedCreateIntermediates, codedAttributes]))
    }
    @ThrowingMock
    public var createDirectory = { (tuple: EquatableTuple<CodableInput>) throws in
        let url: URL = try tuple.inputs[0].decode()
        let createIntermediates: Bool = try tuple.inputs[1].decode()
        let attributes: [FileAttributeKey : Any]? = try tuple.inputs[2].decode()
        try FileManager.default.createDirectory(at: url,
                                                withIntermediateDirectories: createIntermediates,
                                                attributes: attributes)
    }
    
    @Mock
    public var mountedVolumeURLs = { (tuple: EquatableTuple<CodableInput>) -> [URL]? in
        return FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: try! tuple.inputs[0].decode(),
                                                     options: try! tuple.inputs[1].decode())
    }
    public func mountedVolumeURLs(includingResourceValuesForKeys propertyKeys: [URLResourceKey]?, options: FileManager.VolumeEnumerationOptions = []) -> [URL]? {
        return $mountedVolumeURLs.getValue(EquatableTuple([try! CodableInput(propertyKeys), try! CodableInput(options)]))
    }
    
    public var currentDirectoryPath: String = FileManager.default.currentDirectoryPath
    
    @Mock
    public var changeCurrentDirectoryPath = { (path: String) -> Bool in
        return FileManager.default.changeCurrentDirectoryPath(path)
    }
    
    public func changeCurrentDirectoryPath(_ path: String) -> Bool {
        return $changeCurrentDirectoryPath.getValue(path)
    }
}


