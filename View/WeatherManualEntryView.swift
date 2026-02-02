// File: MyTrip5/View/WeatherManualEntryView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI

// This renders manual weather entry for past dates, respecting selected units. (Start)
struct WeatherManualEntryView: View {
    @Bindable var card: TripCard // End card
    let unit: TemperatureUnit // End unit
    let onChanged: () -> Void // End onChanged

    @State private var hiText: String = "" // End hiText
    @State private var lowText: String = "" // End lowText
    @State private var forecastText: String = "" // End forecastText
    @State private var didLoad = false // End didLoad

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weather (manual for past date)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                TextField("Hi \(unitLabel)", text: $hiText)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: hiText) { _, _ in
                        if didLoad { applyHi() } // End if didLoad
                    } // End onChange hiText

                TextField("Low \(unitLabel)", text: $lowText)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: lowText) { _, _ in
                        if didLoad { applyLow() } // End if didLoad
                    } // End onChange lowText
            } // End HStack temps

            TextField("Forecast", text: $forecastText)
                .textFieldStyle(.roundedBorder)
                .onChange(of: forecastText) { _, _ in
                    let trimmed = forecastText.trimmingCharacters(in: .whitespacesAndNewlines)
                    card.manualForecast = trimmed.isEmpty ? nil : trimmed
                    card.touchUpdated()
                    onChanged()
                } // End onChange forecastText
        } // End VStack manual entry
        .onAppear {
            reloadFromModel()
            didLoad = true
        } // End onAppear
        .onChange(of: unitLabel) { _, _ in
            reloadFromModel()
        } // End onChange unitLabel
    } // End body

    private var unitLabel: String {
        switch unit {
        case .celsius:
            return "°C"
        case .fahrenheit:
            return "°F"
        } // End switch unit
    } // End unitLabel

    private func reloadFromModel() {
        hiText = displayText(fromCelsius: card.manualHiC)
        lowText = displayText(fromCelsius: card.manualLowC)
        forecastText = card.manualForecast ?? ""
    } // End func reloadFromModel

    private func displayText(fromCelsius c: Double?) -> String {
        guard let c else { return "" } // End guard c
        let v = displayValue(fromCelsius: c)
        return formatNumber(v)
    } // End func displayText

    private func applyHi() {
        card.manualHiC = parseAndConvertToCelsius(hiText)
        card.touchUpdated()
        onChanged()
    } // End func applyHi

    private func applyLow() {
        card.manualLowC = parseAndConvertToCelsius(lowText)
        card.touchUpdated()
        onChanged()
    } // End func applyLow

    private func parseAndConvertToCelsius(_ raw: String) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil } // End if blank -> nil

        guard let v = parseLocalizedDouble(trimmed) else { return nil } // End guard parsed
        return celsius(fromDisplay: v)
    } // End func parseAndConvertToCelsius

    private func parseLocalizedDouble(_ s: String) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal

        if let n = formatter.number(from: s) { return n.doubleValue } // End if number(from:)

        let alt = s.replacingOccurrences(of: ",", with: ".")
        return Double(alt)
    } // End func parseLocalizedDouble

    private func formatNumber(_ v: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: v)) ?? String(format: "%.0f", v)
    } // End func formatNumber

    private func displayValue(fromCelsius c: Double) -> Double {
        switch unit {
        case .celsius:
            return c
        case .fahrenheit:
            return (c * 9.0 / 5.0) + 32.0
        } // End switch unit
    } // End func displayValue

    private func celsius(fromDisplay v: Double) -> Double {
        switch unit {
        case .celsius:
            return v
        case .fahrenheit:
            return (v - 32.0) * 5.0 / 9.0
        } // End switch unit
    } // End func celsius
} // End WeatherManualEntryView
