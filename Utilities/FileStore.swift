// File: MyTrip5/Utilities/FileStore.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation

// This handles saving generated/imported images to Documents. (Start)
enum FileStore {

    static func savePNG(data: Data, prefix: String) throws -> URL {
        let dir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let name = "\(prefix)\(UUID().uuidString).png"
        let url = dir.appendingPathComponent(name)
        try data.write(to: url, options: [.atomic])
        return url
    } // End savePNG(data:prefix:)

    static func saveBlob(data: Data, prefix: String, ext: String) throws -> URL {
        let dir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let name = "\(prefix)\(UUID().uuidString).\(ext)"
        let url = dir.appendingPathComponent(name)
        try data.write(to: url, options: [.atomic])
        return url
    } // End saveBlob(data:prefix:ext:)

} // End FileStore
// End FileStore.swift
