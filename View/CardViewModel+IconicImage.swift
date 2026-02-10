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
            let url: URL

            if hasPexelsIconicOnCard(pictures: c.pictures) {
                busyMessage = "Generating iconic landmark image…"
                url = try await s.openAIImages.generateIconicLandmarkImage(
                    locationName: c.locationName,
                    timeoutSeconds: 120
                )
            } else {
                url = try await s.openAIImages.generateIconicImage(locationName: c.locationName)
            } // End if/else hasPexels

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

    private func hasPexelsIconicOnCard(pictures: [PictureRef]) -> Bool {
        for ref in pictures {
            if case .url(let s) = ref {
                if AttributionStore.has(provider: .pexels, usage: .iconicPexels, imageURLString: s) { return true } // End if matches attribution
            } // End if case .url
        } // End for ref in pictures
        return false
    } // End func hasPexelsIconicOnCard
} // End extension CardViewModel (iconic image)
