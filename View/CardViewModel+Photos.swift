// File: MyTrip5/View/CardViewModel+Photos.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation

extension CardViewModel {
    struct PickedPhoto {
        let assetIdentifier: String? // End assetIdentifier
        let data: Data? // End data
    } // End PickedPhoto

    func addPickedPhotos(_ photos: [PickedPhoto]) async {
        guard let c = card else { return } // End guard card

        var refs: [PictureRef] = c.pictures

        for photo in photos {
            if let id = photo.assetIdentifier, !id.isEmpty {
                let ref = PictureRef.photoAsset(id: id)
                if !refs.contains(ref) { refs.append(ref) } // End if !contains asset ref
                continue
            } // End if assetIdentifier

            if let data = photo.data,
               let fileURL = try? FileStore.savePNG(data: data, prefix: "photo_") {
                let ref = PictureRef.url(fileURL.absoluteString)
                if !refs.contains(ref) { refs.append(ref) } // End if !contains file ref
            } // End if data->file
        } // End for photo in photos

        c.pictures = refs
        if !refs.isEmpty {
            c.primaryPictureIndex = 0
            imageIndex = 0
        } // End if !refs.isEmpty

        persist()
    } // End func addPickedPhotos

    func deleteCurrentPicture() {
        guard let c = card, c.pictures.indices.contains(imageIndex) else { return } // End guard index valid

        let removed = c.pictures[imageIndex]
        var refs = c.pictures
        refs.remove(at: imageIndex)
        c.pictures = refs

        if case .url(let urlString) = removed, let url = URL(string: urlString), url.isFileURL {
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: url)
            } // End if file exists
        } // End if url file cleanup

        if refs.isEmpty {
            imageIndex = 0
            c.primaryPictureIndex = 0
        } else {
            imageIndex = min(imageIndex, refs.count - 1)
            c.primaryPictureIndex = imageIndex
        } // End if refs.isEmpty

        persist()
    } // End func deleteCurrentPicture
} // End extension CardViewModel (photos)
