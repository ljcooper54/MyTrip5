// File: MyTrip5/View/CardViewModel.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation
import Combine
import SwiftData
import MapKit

@MainActor
final class CardViewModel: ObservableObject {
    @Published var showingMap = false // End showingMap
    @Published var showingDatePicker = false // End showingDatePicker
    @Published var confirmDelete = false // End confirmDelete

    @Published var isBusy = false // End isBusy
    @Published var busyMessage = "Working…" // End busyMessage
    @Published var errorMessage: String? // End errorMessage

    @Published var imageIndex: Int = 0 // End imageIndex
    @Published var isGeneratingIconicImage = false // End isGeneratingIconicImage

    // NOTE: Must be internal (default) so extensions in other files can access.
    weak var card: TripCard? // End card
    var services: AppServices? // End services
    var modelContext: ModelContext? // End modelContext

    func configure(card: TripCard, services: AppServices, modelContext: ModelContext) {
        self.card = card
        self.services = services
        self.modelContext = modelContext
        imageIndex = clampedImageIndex()
    } // End func configure

    func persist() {
        card?.touchUpdated()
        try? modelContext?.save()
    } // End func persist

    func currentCenter() -> CLLocationCoordinate2D {
        if let s = services, let lat = s.settings.lastMapCenterLat, let lon = s.settings.lastMapCenterLon {
            return .init(latitude: lat, longitude: lon)
        } // End if settings center

        if let c = card, let lat = c.latitude, let lon = c.longitude {
            return .init(latitude: lat, longitude: lon)
        } // End if card center

        return .init(latitude: 37.7749, longitude: -122.4194)
    } // End func currentCenter

    func currentSpan() -> MKCoordinateSpan {
        if let s = services,
           let dLat = s.settings.lastMapSpanLatDelta,
           let dLon = s.settings.lastMapSpanLonDelta {
            return .init(latitudeDelta: dLat, longitudeDelta: dLon)
        } // End if settings span

        return .init(latitudeDelta: 0.3, longitudeDelta: 0.3)
    } // End func currentSpan

    func applyMapSelection(_ chosen: MapSelection) async {
        guard let c = card, let s = services else { return } // End guard card/services

        c.latitude = chosen.center.latitude
        c.longitude = chosen.center.longitude

        s.settings.lastMapCenterLat = chosen.center.latitude
        s.settings.lastMapCenterLon = chosen.center.longitude
        s.settings.lastMapSpanLatDelta = chosen.span.latitudeDelta
        s.settings.lastMapSpanLonDelta = chosen.span.longitudeDelta

        if c.locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if let resolved = try? await s.geocoder.reverseGeocode(coord: chosen.center) {
                c.locationName = resolved
            } // End if resolved reverse geocode
        } // End if locationName empty

        persist()
        await refreshWeather(message: "Refreshing weather…")
    } // End func applyMapSelection

    func refreshWeather(message: String) async {
        guard let c = card, let s = services else { return } // End guard card/services

        isBusy = true
        busyMessage = message
        defer { isBusy = false } // End defer busy reset

        do {
            try await WeatherRefresh.refreshIfNeeded(card: c, services: s, force: true)
            try modelContext?.save()
        } catch {
            DebugLog.error("Weather refresh failed: \(error)")
            errorMessage = error.localizedDescription
        } // End do/catch refreshWeather
    } // End func refreshWeather

    func deleteCard() {
        guard let c = card else { return } // End guard card
        modelContext?.delete(c)
        try? modelContext?.save()
    } // End func deleteCard

    func clampedImageIndex() -> Int {
        guard let c = card, !c.pictures.isEmpty else { return 0 } // End guard pictures non-empty
        return min(max(c.primaryPictureIndex, 0), c.pictures.count - 1)
    } // End func clampedImageIndex
} // End CardViewModel
