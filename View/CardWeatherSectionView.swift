//
//  CardWeatherSectionView.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/31/26.
//


// File: MyTrip5/View/CardWeatherSectionView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI

struct CardWeatherSectionView: View {
    @Bindable var card: TripCard
    let services: AppServices
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if card.date < Calendar.current.startOfDay(for: Date()) {
                manualWeatherEditor
            } else {
                Text(weatherLine(snapshot: card.weather))
                    .font(.subheadline)
                    .foregroundStyle((card.weather?.forecast == "No Weather") ? .secondary : .primary)
            } // End if/else past-date weather
        } // End VStack weather section
    } // End body

    private var manualWeatherEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weather (manual for past date)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                TextField("Hi °C", value: $card.manualHiC, format: .number)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(.roundedBorder)

                TextField("Low °C", value: $card.manualLowC, format: .number)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(.roundedBorder)
            } // End HStack temps

            TextField(
                "Forecast",
                text: Binding(
                    get: { card.manualForecast ?? "" },
                    set: { card.manualForecast = $0 } // End Binding setter
                ) // End Binding
            )
            .textFieldStyle(.roundedBorder)

            Button("Refresh Weather") { onRefresh() }
                .buttonStyle(.bordered)
        } // End VStack manual weather editor (long)
    } // End manualWeatherEditor

    private func weatherLine(snapshot: WeatherSnapshot?) -> String {
        guard let snapshot else { return "No Weather" } // End guard snapshot
        if snapshot.forecast == "No Weather" { return "No Weather" } // End if no weather

        let unit = services.settings.temperatureUnit
        let hi = snapshot.hiC.map { unit.display(celsius: $0) }
        let lo = snapshot.lowC.map { unit.display(celsius: $0) }

        let hiText = hi.map { String(format: "%.0f%@", $0, unit.label) } ?? "--"
        let loText = lo.map { String(format: "%.0f%@", $0, unit.label) } ?? "--"

        var parts = ["Hi \(hiText)", "Low \(loText)"]
        if let f = snapshot.forecast, !f.isEmpty { parts.append("Forecast \(f)") } // End if forecast
        if let r = snapshot.rainChance { parts.append("Rain \(Int(r * 100))%") } // End if rain
        if let s = snapshot.snowChance { parts.append("Snow \(Int(s * 100))%") } // End if snow
        return parts.joined(separator: "  ")
    } // End func weatherLine
} // End CardWeatherSectionView