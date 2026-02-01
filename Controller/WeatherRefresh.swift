//
//  WeatherRefresh.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/28/26.
//


// File: MyTrip5/Controller/WeatherRefresh.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation
import CoreLocation

// This enforces the “within 14 days + 20 hours” refresh rule. (Start)
enum WeatherRefresh {
    static func refreshIfNeeded(card: TripCard, services: AppServices, force: Bool = false) async throws {
        let today = Calendar.current.startOfDay(for: Date())
        let cardDay = Calendar.current.startOfDay(for: card.date)

        let dayDiff = Calendar.current.dateComponents([.day], from: today, to: cardDay).day ?? 9999
        guard dayDiff >= 0 && dayDiff <= 14 else {
            card.weather = WeatherSnapshot.noWeather()
            return
        }

        if cardDay < today {
            return
        }

        if !force, let last = card.weather?.updatedAt {
            if Date().timeIntervalSince(last) < (20.0 * 3600.0) {
                return
            }
        }

        let coord: CLLocationCoordinate2D
        if let lat = card.latitude, let lon = card.longitude {
            coord = .init(latitude: lat, longitude: lon)
        } else if !card.locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            coord = try await services.geocoder.forwardGeocode(name: card.locationName)
            card.latitude = coord.latitude
            card.longitude = coord.longitude
        } else {
            card.weather = WeatherSnapshot.noWeather()
            return
        }

        let snap = try await services.openWeather.fetchWeatherSnapshot(for: card.date, coord: coord)
        card.weather = snap
    }
}
// End WeatherRefresh