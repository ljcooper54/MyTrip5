//
//  PDFCardHeaderTextBuilder.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 2/2/26.
//


// ==============================
// File: MyTrip5/Utilities/PDFCardHeaderTextBuilder.swift
// ==============================

import Foundation
import UIKit

// Builds the bold header used on each card section in the Cards PDF. (Start)
enum PDFCardHeaderTextBuilder {
    static func build(card: TripCard, unit: TemperatureUnit) -> NSAttributedString {
        let date = DateFormatter.localizedString(from: card.date, dateStyle: .medium, timeStyle: .none)
        let location = card.locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Unnamed location" : card.locationName
        let weather = PDFWeatherStringBuilder.build(card: card, unit: unit)

        let title = "\(date)  •  \(location)\n\(weather)"
        let out = NSMutableAttributedString(string: title)

        out.addAttributes([.font: UIFont.boldSystemFont(ofSize: 14)], range: NSRange(location: 0, length: title.count))

        if let lb = title.firstIndex(of: "\n") {
            let i = title.distance(from: title.startIndex, to: lb) + 1
            out.addAttributes([.font: UIFont.boldSystemFont(ofSize: 12)], range: NSRange(location: i, length: max(0, title.count - i)))
        } // End if lb

        return out
    } // End func build (long)
} // End enum PDFCardHeaderTextBuilder

// Weather string used by PDFs; prefers manual fields for past-dated cards. (Start)
enum PDFWeatherStringBuilder {
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

        return "No Weather"
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
} // End enum PDFWeatherStringBuilder