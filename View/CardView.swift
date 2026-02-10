// Copyright 2025 H2so4 Consulting LLC
// File: MyTrip5/View/CardView.swift
// This renders an editable TripCard and wires child sections. (Start)

import SwiftUI
import SwiftData
import CoreLocation
import MapKit

struct CardView: View {
    @Environment(\.modelContext) private var modelContext // End modelContext
    @EnvironmentObject private var services: AppServices // End services

    @Bindable var card: TripCard // End card

    let canGoPrevCard: Bool // End canGoPrevCard
    let canGoNextCard: Bool // End canGoNextCard
    let goPrevCard: () -> Void // End goPrevCard
    let goNextCard: () -> Void // End goNextCard

    @State private var showingMap = false // End showingMap
    @State private var confirmDelete = false // End confirmDelete

    @State private var imageIndex: Int = 0 // End imageIndex
    @State private var isGeneratingIconic = false // End isGeneratingIconic
    @State private var iconicTask: Task<Void, Never>? = nil // End iconicTask

    // NEW: Pexels candidates for cycling the iconic image (not persisted)
    @State private var pexelsIconicCandidates: [String] = [] // End pexelsIconicCandidates
    @State private var pexelsIconicCandidateIndex: Int = 0 // End pexelsIconicCandidateIndex

    var body: some View {
        VStack(spacing: 12) {
            CardHeaderRowView(
                card: card,
                onShowMap: { showingMap = true },
                onChanged: persist
            ) // End CardHeaderRowView

            CardWeatherSectionView(
                card: card,
                temperatureUnit: services.settings.temperatureUnit,
                onChanged: persist,
                onRefreshWeather: { Task { await forceRefreshWeather() } }
            ) // End CardWeatherSectionView

            CardPicturesSectionView(
                card: card,
                canGoPrevCard: canGoPrevCard,
                canGoNextCard: canGoNextCard,
                goPrevCard: goPrevCard,
                goNextCard: goNextCard,
                imageIndex: $imageIndex,
                isGeneratingAI: $isGeneratingIconic,
                showPexelsCycle: shouldShowPexelsCycleArrow(),
                onCyclePexels: cyclePexelsIconicCandidate,
                onDeleteCurrent: deleteCurrentPicture,
                onPhotosPicked: applyPickedPhotos(_:),
                onGenerateAI: generateIconicImage,
                onCancelGenerateAI: cancelIconicImage
            ) // End CardPicturesSectionView

            CardActionsRowView(
                onPickFromMap: { showingMap = true },
                onRefreshWeather: { Task { await forceRefreshWeather() } }
            ) // End CardActionsRowView

            Spacer(minLength: 0)

            CardDeleteRowView { confirmDelete = true } // End CardDeleteRowView
        } // End VStack
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear { imageIndex = clampedImageIndex() } // End onAppear
        .onChange(of: imageIndex) { _, newValue in
            card.primaryPictureIndex = newValue
            card.touchUpdated()
            persist()
        } // End onChange imageIndex
        .sheet(isPresented: $showingMap) {
            MapPickerView(
                initialCenter: currentCenter(),
                initialSpan: currentSpan()
            ) { chosen in
                Task { await applyMapSelection(chosen) } // End Task applyMapSelection
            } // End MapPickerView
        } // End sheet
        .alert("Delete card?", isPresented: $confirmDelete) {
            Button("Delete", role: .destructive) {
                modelContext.delete(card)
                persist()
            } // End Button Delete
            Button("Cancel", role: .cancel) { } // End Button Cancel
        } message: {
            Text("This cannot be undone.")
        } // End alert
    } // End body

    private func persist() {
        try? modelContext.save()
    } // End func persist

    private func clampedImageIndex() -> Int {
        if card.pictures.isEmpty { return 0 } // End if empty
        return min(max(card.primaryPictureIndex, 0), card.pictures.count - 1)
    } // End func clampedImageIndex

    private func deleteCurrentPicture() {
        guard !card.pictures.isEmpty else { return } // End guard has pictures
        let safeIndex = min(max(0, imageIndex), card.pictures.count - 1)
        card.pictures.remove(at: safeIndex)
        imageIndex = min(max(0, imageIndex), max(0, card.pictures.count - 1))
        card.primaryPictureIndex = imageIndex
        card.touchUpdated()

        // If the primary (index 0) was removed, discard cycle candidates (they no longer match).
        if safeIndex == 0 {
            pexelsIconicCandidates = []
            pexelsIconicCandidateIndex = 0
        } // End if removed primary

        persist()
    } // End func deleteCurrentPicture

    private func cancelIconicImage() {
        iconicTask?.cancel()
        iconicTask = nil
        isGeneratingIconic = false
    } // End func cancelIconicImage

    private func generateIconicImage() async {
        guard iconicTask == nil else { return } // End guard no existing task
        let task = Task { await generateIconicImageFlow() } // End Task create
        iconicTask = task
        await task.value
    } // End func generateIconicImage

    private func generateIconicImageFlow() async {
        isGeneratingIconic = true
        defer { isGeneratingIconic = false; iconicTask = nil } // End defer reset flags

        do {
            if hasPexelsIconicOnCard() {
                // Once a Pexels iconic has been used anywhere on this card, the button generates an OpenAI image.
                pexelsIconicCandidates = []
                pexelsIconicCandidateIndex = 0

                let url = try await services.openAIImages.generateIconicLandmarkImage(
                    locationName: card.locationName,
                    timeoutSeconds: 120
                )
                try Task.checkCancellation() // End cancellation checkpoint

                var refs = card.pictures
                refs.insert(.url(url.absoluteString), at: 0)
                card.pictures = refs
                card.primaryPictureIndex = 0
                imageIndex = 0
                card.touchUpdated()
                persist()
            } else {
                // First-time Pexels iconic: fetch multiple matches and enable cycling.
                let urls = try await services.openAIImages.searchPexelsIconicImages(locationName: card.locationName, perPage: 5)
                try Task.checkCancellation() // End cancellation checkpoint

                let candidates = urls.map { $0.absoluteString }
                pexelsIconicCandidates = candidates
                pexelsIconicCandidateIndex = 0

                var refs = card.pictures
                refs.insert(.url(candidates[0]), at: 0)
                card.pictures = refs
                card.primaryPictureIndex = 0
                imageIndex = 0
                card.touchUpdated()
                persist()
            } // End if/else pexels already exists
        } catch is CancellationError {
            #if DEBUG
            DebugLog.api("Iconic image generation cancelled")
            #endif
        } catch {
            DebugLog.error("Iconic image generation failed: \(error)")
        } // End do/catch generateIconicImageFlow
    } // End func generateIconicImageFlow (long)

    private func hasPexelsIconicOnCard() -> Bool {
        for ref in card.pictures {
            if case .url(let s) = ref {
                if AttributionStore.has(provider: .pexels, usage: .iconicPexels, imageURLString: s) { return true } // End if match attribution
            } // End if case .url
        } // End for ref in pictures
        return false
    } // End func hasPexelsIconicOnCard

    private func shouldShowPexelsCycleArrow() -> Bool {
        guard pexelsIconicCandidates.count > 1 else { return false } // End guard candidates
        guard imageIndex == 0 else { return false } // End guard primary only
        guard !card.pictures.isEmpty else { return false } // End guard pictures

        if case .url(let s) = card.pictures[0] {
            return pexelsIconicCandidates.contains(s)
        } // End if case .url

        return false
    } // End func shouldShowPexelsCycleArrow

    private func cyclePexelsIconicCandidate() {
        guard pexelsIconicCandidates.count > 1 else { return } // End guard candidates
        guard !card.pictures.isEmpty else { return } // End guard pictures
        guard imageIndex == 0 else { return } // End guard primary only

        pexelsIconicCandidateIndex = (pexelsIconicCandidateIndex + 1) % pexelsIconicCandidates.count
        let next = pexelsIconicCandidates[pexelsIconicCandidateIndex]

        card.pictures[0] = .url(next)
        card.primaryPictureIndex = 0
        imageIndex = 0
        card.touchUpdated()
        persist()
    } // End func cyclePexelsIconicCandidate

    private func applyPickedPhotos(_ picked: [CardViewModel.PickedPhoto]) async {
        await MainActor.run {
            // no-op; keeps UI responsive for very large picks
        } // End MainActor warmup

        var newRefs: [PictureRef] = card.pictures

        for p in picked {
            if let id = p.assetIdentifier {
                let ref = PictureRef.photoAsset(id: id)
                if !newRefs.contains(ref) { newRefs.append(ref) } // End if !contains
                continue
            } // End if let id

            if let data = p.data,
               let fileURL = try? FileStore.savePNG(data: data, prefix: "photo_") {
                let ref = PictureRef.url(fileURL.absoluteString)
                if !newRefs.contains(ref) { newRefs.append(ref) } // End if !contains
            } // End if data save
        } // End for p in picked

        await MainActor.run {
            card.pictures = newRefs
            if !newRefs.isEmpty {
                card.primaryPictureIndex = 0
                imageIndex = 0
            } // End if !empty
            card.touchUpdated()
            persist()
        } // End MainActor apply refs
    } // End func applyPickedPhotos (long)

    private func forceRefreshWeather() async {
        do {
            try await WeatherRefresh.refreshIfNeeded(card: card, services: services, force: true)
            persist()
        } catch {
            DebugLog.error("Weather refresh failed: \(error)")
        } // End do/catch forceRefreshWeather
    } // End func forceRefreshWeather

    private func currentCenter() -> CLLocationCoordinate2D {
        if let lat = services.settings.lastMapCenterLat, let lon = services.settings.lastMapCenterLon {
            return .init(latitude: lat, longitude: lon)
        } // End if settings center
        if let lat = card.latitude, let lon = card.longitude {
            return .init(latitude: lat, longitude: lon)
        } // End if card center
        return .init(latitude: 37.7749, longitude: -122.4194)
    } // End func currentCenter

    private func currentSpan() -> MKCoordinateSpan {
        if let dLat = services.settings.lastMapSpanLatDelta, let dLon = services.settings.lastMapSpanLonDelta {
            return .init(latitudeDelta: dLat, longitudeDelta: dLon)
        } // End if settings span
        return .init(latitudeDelta: 0.3, longitudeDelta: 0.3)
    } // End func currentSpan

    private func applyMapSelection(_ chosen: MapSelection) async {
        card.latitude = chosen.center.latitude
        card.longitude = chosen.center.longitude

        services.settings.lastMapCenterLat = chosen.center.latitude
        services.settings.lastMapCenterLon = chosen.center.longitude
        services.settings.lastMapSpanLatDelta = chosen.span.latitudeDelta
        services.settings.lastMapSpanLonDelta = chosen.span.longitudeDelta

        card.touchUpdated()
        persist()

        await forceRefreshWeather()
    } // End func applyMapSelection (long)
} // End CardView
