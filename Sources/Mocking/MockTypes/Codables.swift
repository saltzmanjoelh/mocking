//
//  Codables.swift
//  
//
//  Created by Joel Saltzman on 5/23/21.
//

import Foundation

// Simple Codable conformance for types that don't have it specified already.

extension URLResourceKey: Codable { }
extension FileManager.DirectoryEnumerationOptions: Codable { }
extension FileAttributeKey: Codable { }
extension FileManager.VolumeEnumerationOptions: Codable { }
