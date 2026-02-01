//
//  WeatherSnapshot.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/28/26.
//


// File: MyTrip5/Model/WeatherSnapshot.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation

// This stores weather for a card (metric internally, UI converts). (Start)
struct WeatherSnapshot: Codable, Equatable {
    var hiC: Double?
    var lowC: Double?
    var forecast: String?
    var rainChance: Double?    // 0..1 (when available)
    var snowChance: Double?    // 0..1 (when available)

    var updatedAt: Date
    var source: WeatherSource

    static func noWeather() -> WeatherSnapshot {
        WeatherSnapshot(
            hiC: nil, lowC: nil,
            forecast: "No Weather",
            rainChance: nil, snowChance: nil,
            updatedAt: Date(),
            source: .none
        )
    }

    static func decode(_ data: Data?) -> WeatherSnapshot? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(WeatherSnapshot.self, from: data)
    }

    func encode() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

enum WeatherSource: String, Codable {
    case oneCallDaily
    case daySummary
    case manual
    case none
}
// End WeatherSnapshot