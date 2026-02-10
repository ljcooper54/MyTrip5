//
//  PicturePDFImageLoader.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 2/2/26.
//


// ==============================
// File: MyTrip5/Utilities/PicturePDFImageLoader.swift
// ==============================

import Foundation
import UIKit
import Photos

// Loads images for PDF generation; missing local files are silently skipped. (Start)
enum PicturePDFImageLoader {
    static func loadUIImage(from ref: PictureRef) async throws -> UIImage? {
        if case .url(let s) = ref {
            return await loadFromURLString(s)
        } // End if case .url

        if case .photoAsset(id: let id) = ref {
            return try await loadFromPhotoAsset(identifier: id)
        } // End if case .photoAsset

        return nil
    } // End func loadUIImage (long)

    private static func loadFromURLString(_ s: String) async -> UIImage? {
        guard let url = URL(string: s) else { return nil } // End guard url

        if url.isFileURL {
            if !FileManager.default.fileExists(atPath: url.path) { return nil } // End if missing file
            guard let data = try? Data(contentsOf: url), let img = UIImage(data: data) else { return nil } // End guard decode
            return img
        } // End if fileURL

        var req = URLRequest(url: url)
        req.timeoutInterval = 25

        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            return UIImage(data: data)
        } catch {
            #if DEBUG
            DebugLog.api("Skipping remote image load failure: \(error)")
            #endif
            return nil
        } // End do/catch
    } // End func loadFromURLString (long)

    private static func loadFromPhotoAsset(identifier: String) async throws -> UIImage? {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        guard let asset = assets.firstObject else { return nil } // End guard asset

        return await withCheckedContinuation { cont in
            let opts = PHImageRequestOptions()
            opts.isSynchronous = false
            opts.deliveryMode = .highQualityFormat
            opts.resizeMode = .fast
            opts.isNetworkAccessAllowed = true

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 1600, height: 1600),
                contentMode: .aspectFit,
                options: opts
            ) { image, _ in
                cont.resume(returning: image)
            } // End requestImage completion
        } // End withCheckedContinuation
    } // End func loadFromPhotoAsset (long)
} // End enum PicturePDFImageLoader