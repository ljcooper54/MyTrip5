// File: MyTrip5/View/CardViewModel+IconicImage.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation

extension CardViewModel {
    func fetchIconicImage() async {
        guard let c = card, let s = services else { return } // End guard card/services

        isGeneratingIconicImage = true
        isBusy = true
        busyMessage = "Fetching iconic image…"
        defer { isGeneratingIconicImage = false; isBusy = false } // End defer flags reset

        do {
            let url = try await s.openAIImages.generateIconicImage(locationName: c.locationName)

            #if DEBUG
            DebugLog.api("Iconic image URL: \(url.absoluteString)")
            #endif

            var refs: [PictureRef] = c.pictures
            refs.insert(PictureRef.url(url.absoluteString), at: 0)
            c.pictures = refs
            c.primaryPictureIndex = 0
            imageIndex = 0
            persist()
        } catch {
            DebugLog.error("Iconic image fetch failed: \(error)")
            errorMessage = error.localizedDescription
        } // End do/catch fetchIconicImage
    } // End func fetchIconicImage
} // End extension CardViewModel (iconic image)
