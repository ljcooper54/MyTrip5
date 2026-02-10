// File: MyTrip5/Utilities/ItineraryImportService.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation
import SwiftData
import MapKit
import CoreLocation

enum ItineraryImportService {
    @MainActor
    static func createCards(stops: [ItineraryStop], services: AppServices, modelContext: ModelContext) async throws {
        let dailyStops = expandStopsToDays(stops: stops) // End let dailyStops

        for item in dailyStops {
            if Task.isCancelled { return } // End if cancelled

            let card = TripCard()
            modelContext.insert(card)

            card.date = item.date
            card.locationName = item.locationName
            card.pictures = []
            card.primaryPictureIndex = 0

            card.manualHiC = nil
            card.manualLowC = nil
            card.manualForecast = nil

            do {
                let coord = try await geocode(address: item.locationName)
                card.latitude = coord.latitude
                card.longitude = coord.longitude
            } catch {
                #if DEBUG
                DebugLog.api("Import geocode failed for \(item.locationName): \(error)")
                #endif
            } // End do/catch geocode

            card.touchUpdated()

            do {
                try await WeatherRefresh.refreshIfNeeded(card: card, services: services, force: true)
            } catch {
                #if DEBUG
                DebugLog.api("Import weather refresh failed for \(item.locationName): \(error)")
                #endif
            } // End do/catch refreshIfNeeded
        } // End for item in dailyStops

        try modelContext.save()
    } // End func createCards (long)

    private static func expandStopsToDays(stops: [ItineraryStop]) -> [DailyStop] {
        var out: [DailyStop] = []

        for s in stops {
            let start = Calendar.current.startOfDay(for: s.startDate)
            let end = Calendar.current.startOfDay(for: s.endDate)
            let lo = min(start, end)
            let hi = max(start, end)

            var d = lo
            while d <= hi {
                out.append(.init(locationName: s.locationName, date: d))
                d = Calendar.current.date(byAdding: .day, value: 1, to: d) ?? hi.addingTimeInterval(86400)
            } // End while d <= hi
        } // End for s in stops

        return out
    } // End func expandStopsToDays (long)

    private static func geocode(address: String) async throws -> CLLocationCoordinate2D {
        let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw NSError(domain: "ItineraryImport", code: 400, userInfo: [NSLocalizedDescriptionKey: "Empty location name"])
        } // End guard trimmed

        guard let request = MKGeocodingRequest(addressString: trimmed) else {
            throw NSError(domain: "ItineraryImport", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid address: \(trimmed)"])
        } // End guard request

        let items = try await request.mapItems
        guard let first = items.first else {
            throw NSError(domain: "ItineraryImport", code: 404, userInfo: [NSLocalizedDescriptionKey: "No match for \(trimmed)"])
        } // End guard first

        let loc = first.location // location is non-optional in this SDK // End let loc
        return loc.coordinate
    } // End func geocode (long)
} // End enum ItineraryImportService

struct DailyStop {
    let locationName: String // End locationName
    let date: Date // End date
} // End struct DailyStop
