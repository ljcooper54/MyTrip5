// File: MyTrip5/Controller/AppSettings.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation
import MapKit

// This stores user preferences and last-known map camera settings. (Start)
struct AppSettings: Codable, Equatable {
    var temperatureUnit: TemperatureUnit = .celsius
    var lastMapCenterLat: Double?
    var lastMapCenterLon: Double?
    var lastMapSpanLatDelta: Double?
    var lastMapSpanLonDelta: Double?

    static let defaultsKey = "MyTrip5.AppSettings"

    static func load() -> AppSettings {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let decoded = try? JSONDecoder().decode(AppSettings.self, from: data)
        else { return AppSettings() } // End guard decode
        return decoded
    } // End load()

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return } // End guard encode
        UserDefaults.standard.set(data, forKey: Self.defaultsKey)
    } // End save()

} // End AppSettings

// This defines supported temperature display units and conversion. (Start)
enum TemperatureUnit: String, Codable, CaseIterable {
    case celsius
    case fahrenheit

    var label: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        } // End switch self
    } // End label

    func display(celsius: Double) -> Double {
        switch self {
        case .celsius:
            return celsius
        case .fahrenheit:
            return (celsius * 9.0 / 5.0) + 32.0
        } // End switch self
    } // End display(celsius:)

} // End TemperatureUnit
// End AppSettings.swift
