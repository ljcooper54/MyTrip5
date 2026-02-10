//
//  CSVExportService.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 2/2/26.
//


// ==============================
// File: MyTrip5/Utilities/CSVExportService.swift  (NEW)
// ==============================

import Foundation

// Exports table-view data as a CSV file. (Start)
enum CSVExportService {
    static func makeTableCSV(cards: [TripCard], temperatureUnit: TemperatureUnit) throws -> URL {
        let header = ["Date", "Location", "Weather", "Pictures"].map(csvEscape).joined(separator: ",") + "\n" // End header
        var body = ""

        let df = DateFormatter()
        df.locale = Locale.current
        df.dateStyle = .medium
        df.timeStyle = .none

        for card in cards {
            let date = df.string(from: card.date)
            let location = card.locationName.trimmingCharacters(in: .whitespacesAndNewlines)
            let weather = CSVWeatherStringBuilder.build(card: card, unit: temperatureUnit)
            let pics = "\(card.pictures.count)"

            let row = [
                csvEscape(date),
                csvEscape(location.isEmpty ? "Unnamed location" : location),
                csvEscape(weather),
                csvEscape(pics)
            ].joined(separator: ",") + "\n"

            body += row
        } // End for card in cards

        let csv = header + body
        return try saveCSV(csv, prefix: "table_")
    } // End func makeTableCSV (long)

    private static func saveCSV(_ csv: String, prefix: String) throws -> URL {
        let dir = FileManager.default.temporaryDirectory
        let name = "\(prefix)\(Int(Date().timeIntervalSince1970)).csv"
        let url = dir.appendingPathComponent(name)
        try csv.data(using: .utf8)?.write(to: url, options: [.atomic])
        return url
    } // End func saveCSV

    nonisolated private static func csvEscape(_ s: String) -> String {
        if s.contains(",") || s.contains("\"") || s.contains("\n") || s.contains("\r") {
            let escaped = s.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        } // End if needs quoting
        return s
    } // End func csvEscape
} // End CSVExportService

// CSV weather formatting; prefers manual fields for past dates. (Start)
enum CSVWeatherStringBuilder {
    static func build(card: TripCard, unit: TemperatureUnit) -> String {
        let isPast = card.date < Calendar.current.startOfDay(for: Date())

        if isPast {
            let hi = card.manualHiC.map { unitDisplay(celsius: $0, unit: unit) }
            let lo = card.manualLowC.map { unitDisplay(celsius: $0, unit: unit) }
            let f = card.manualForecast?.trimmingCharacters(in: .whitespacesAndNewlines)

            var parts: [String] = []
            if let hi { parts.append("Hi \(hi)") } // End if hi
            if let lo { parts.append("Low \(lo)") } // End if lo
            if let f, !f.isEmpty { parts.append(f) } // End if f

            if !parts.isEmpty { return parts.joined(separator: "  ") } // End if parts
        } // End if isPast

        if let snap = card.weather {
            let m = Mirror(reflecting: snap)
            var forecast: String? = nil
            var hiC: Double? = nil
            var lowC: Double? = nil

            for c in m.children {
                if c.label == "forecast", let v = c.value as? String { forecast = v } // End if forecast
                if c.label == "hiC", let v = c.value as? Double { hiC = v } // End if hiC
                if c.label == "lowC", let v = c.value as? Double { lowC = v } // End if lowC
            } // End for c in children

            var parts: [String] = []
            if let forecast, !forecast.isEmpty { parts.append(forecast) } // End if forecast
            if let hiC { parts.append("Hi \(unitDisplay(celsius: hiC, unit: unit))") } // End if hiC
            if let lowC { parts.append("Low \(unitDisplay(celsius: lowC, unit: unit))") } // End if lowC
            if !parts.isEmpty { return parts.joined(separator: "  ") } // End if parts
        } // End if snap

        return ""
    } // End func build (long)

    private static func unitDisplay(celsius: Double, unit: TemperatureUnit) -> String {
        let v: Double
        let suffix: String

        switch unit {
        case .celsius:
            v = celsius
            suffix = "°C"
        case .fahrenheit:
            v = (celsius * 9.0 / 5.0) + 32.0
            suffix = "°F"
        } // End switch unit

        return String(format: "%.0f%@", v, suffix)
    } // End func unitDisplay
} // End CSVWeatherStringBuilder
