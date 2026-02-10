// ==============================
// File: MyTrip5/Utilities/FileStore.swift   (NEW or REPLACE EXISTING)
// ==============================

import Foundation

// Centralized persistent file storage for generated/selected images. (Start)
enum FileStore {
    static func savePNG(data: Data, prefix: String) throws -> URL {
        let dir = try imagesDirectory()
        let ext = sniffImageExtension(data: data)
        let name = "\(prefix)\(Int(Date().timeIntervalSince1970))_\(UUID().uuidString).\(ext)"
        let url = dir.appendingPathComponent(name)

        try data.write(to: url, options: [.atomic])
        return url
    } // End func savePNG

    static func fileExists(_ url: URL) -> Bool {
        guard url.isFileURL else { return false } // End guard fileURL
        return FileManager.default.fileExists(atPath: url.path)
    } // End func fileExists

    static func imagesDirectory() throws -> URL {
        let fm = FileManager.default
        let base = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

        let appDir = base.appendingPathComponent("MyTrip5", isDirectory: true)
        let imgDir = appDir.appendingPathComponent("Images", isDirectory: true)

        if !fm.fileExists(atPath: imgDir.path) {
            try fm.createDirectory(at: imgDir, withIntermediateDirectories: true)
        } // End if createDirectory

        return imgDir
    } // End func imagesDirectory (long)

    private static func sniffImageExtension(data: Data) -> String {
        // PNG signature: 89 50 4E 47 0D 0A 1A 0A
        if data.count >= 8 {
            let sig = [UInt8](data.prefix(8))
            if sig == [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A] { return "png" } // End if png
        } // End if count >= 8

        // JPEG signature: FF D8
        if data.count >= 2 {
            let sig2 = [UInt8](data.prefix(2))
            if sig2 == [0xFF, 0xD8] { return "jpg" } // End if jpg
        } // End if count >= 2

        return "png"
    } // End func sniffImageExtension
} // End FileStore
