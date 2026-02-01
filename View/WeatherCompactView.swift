//
//  WeatherCompactView.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/28/26.
//


// File: MyTrip5/View/WeatherCompactView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI

// This renders compact weather for table mode. (Start)
struct WeatherCompactView: View {
    @EnvironmentObject private var services: AppServices
    let card: TripCard

    var body: some View {
        let snap = cardEffectiveWeather(card)
        let unit = services.settings.temperatureUnit

        VStack(alignment: .trailing, spacing: 2) {
            if let hi = snap?.hiC, let lo = snap?.lowC {
                Text("H \(format(unit.display(celsius: hi)))  L \(format(unit.display(celsius: lo)))")
                    .font(.subheadline)
            } else {
                Text("No Weather").font(.subheadline).foregroundStyle(.secondary)
            }
            Text(snap?.forecast ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(minWidth: 140, alignment: .trailing)
    }

    private func cardEffectiveWeather(_ card: TripCard) -> WeatherSnapshot? {
        if card.date < Calendar.current.startOfDay(for: Date()) {
            if let hi = card.manualHiC, let lo = card.manualLowC, let f = card.manualForecast, !f.isEmpty {
                return WeatherSnapshot(hiC: hi, lowC: lo, forecast: f, rainChance: nil, snowChance: nil, updatedAt: Date(), source: .manual)
            }
        }
        return card.weather
    }

    private func format(_ v: Double) -> String {
        String(format: "%.0f%@", v, services.settings.temperatureUnit.label)
    }
}
// End WeatherCompactView
