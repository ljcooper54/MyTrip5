// =======================================
// File: MyTrip5/View/CardWeatherSectionView.swift   (NEW)
// =======================================

import SwiftUI

// This renders weather and manual entry for past dates using selected units. (Start)
struct CardWeatherSectionView: View {
    @Bindable var card: TripCard // End card
    let temperatureUnit: TemperatureUnit // End temperatureUnit
    let onChanged: () -> Void // End onChanged
    let onRefreshWeather: () -> Void // End onRefreshWeather

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let isPast = card.date < Calendar.current.startOfDay(for: Date())

            if isPast {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weather (manual for past date)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        TextField("Hi \(temperatureUnit.label)", value: hiBinding(), format: .number)
                            .keyboardType(.numbersAndPunctuation)
                            .textFieldStyle(.roundedBorder)

                        TextField("Low \(temperatureUnit.label)", value: lowBinding(), format: .number)
                            .keyboardType(.numbersAndPunctuation)
                            .textFieldStyle(.roundedBorder)
                    } // End HStack hi/low

                    TextField(
                        "Forecast",
                        text: Binding(
                            get: { card.manualForecast ?? "" },
                            set: { card.manualForecast = $0 }
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: card.manualForecast ?? "") { _, _ in
                        card.touchUpdated()
                        onChanged()
                    } // End onChange forecast
                } // End VStack manual entry
            } else {
                HStack {
                    Text(weatherLine(snapshot: card.weather))
                        .font(.subheadline)
                        .foregroundStyle((card.weather?.forecast == "No Weather") ? .secondary : .primary)

                    Spacer()

                    Button("Refresh") { onRefreshWeather() } // End Button Refresh
                        .buttonStyle(.bordered)
                } // End HStack weather line
            } // End if/else isPast
        } // End VStack weather section (long)
    } // End body

    private func hiBinding() -> Binding<Double> {
        Binding(
            get: { displayValue(fromCelsius: card.manualHiC ?? 0) },
            set: { newValue in
                card.manualHiC = celsius(fromDisplay: newValue)
                card.touchUpdated()
                onChanged()
            } // End set
        )
    } // End func hiBinding

    private func lowBinding() -> Binding<Double> {
        Binding(
            get: { displayValue(fromCelsius: card.manualLowC ?? 0) },
            set: { newValue in
                card.manualLowC = celsius(fromDisplay: newValue)
                card.touchUpdated()
                onChanged()
            } // End set
        )
    } // End func lowBinding

    private func displayValue(fromCelsius c: Double) -> Double {
        switch temperatureUnit {
        case .celsius:
            return c
        case .fahrenheit:
            return (c * 9.0 / 5.0) + 32.0
        } // End switch temperatureUnit
    } // End func displayValue

    private func celsius(fromDisplay v: Double) -> Double {
        switch temperatureUnit {
        case .celsius:
            return v
        case .fahrenheit:
            return (v - 32.0) * 5.0 / 9.0
        } // End switch temperatureUnit
    } // End func celsius

    private func weatherLine(snapshot: WeatherSnapshot?) -> String {
        guard let snapshot else { return "No Weather" } // End guard snapshot
        if snapshot.forecast == "No Weather" { return "No Weather" } // End if no weather

        let hi = snapshot.hiC.map { temperatureUnit.display(celsius: $0) }
        let lo = snapshot.lowC.map { temperatureUnit.display(celsius: $0) }

        let hiText = hi.map { String(format: "%.0f%@", $0, temperatureUnit.label) } ?? "--"
        let loText = lo.map { String(format: "%.0f%@", $0, temperatureUnit.label) } ?? "--"

        var parts = ["Hi \(hiText)", "Low \(loText)"]
        if let f = snapshot.forecast, !f.isEmpty { parts.append("Forecast \(f)") } // End if forecast
        if let r = snapshot.rainChance { parts.append("Rain \(Int(r * 100))%") } // End if rainChance
        if let s = snapshot.snowChance { parts.append("Snow \(Int(s * 100))%") } // End if snowChance
        return parts.joined(separator: "  ")
    } // End func weatherLine (long)
} // End CardWeatherSectionView
