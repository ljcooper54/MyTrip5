// File: MyTrip5/View/SettingsView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI

// This shows the hamburger menu content (unit toggle + About + Thanks To). (Start)
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss // End dismiss
    @EnvironmentObject private var services: AppServices // End services

    var body: some View {
        NavigationStack {
            Form {
                Section("Units") {
                    Picker("Temperature", selection: $services.settings.temperatureUnit) {
                        ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                            Text(unit == .celsius ? "Celsius" : "Fahrenheit").tag(unit)
                        } // End ForEach TemperatureUnit
                    } // End Picker Temperature
                    .pickerStyle(.segmented)

                    Text("Database and API calls are always in Celsius (metric).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } // End Section Units

                Section("Thanks To") {
                    NavigationLink("Thanks To") {
                        ThanksToView()
                    } // End NavigationLink ThanksToView

                    Text("Attribution for downloaded photos is listed here.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } // End Section Thanks To

                Section("About") {
                    Text("MyTrip (C) 2026 H2so4 Consulting LLC.  All rights reserved.")
                        .font(.callout)
                } // End Section About

                #if DEBUG
                Section("Debug") {
                    Text(debugKeysLine())
                        .foregroundStyle(debugKeysConfigured() ? .green : .red)
                } // End Section Debug
                #endif
            } // End Form
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() } // End Button Done
                } // End ToolbarItem Done
            } // End toolbar
        } // End NavigationStack (long)
    } // End body

    #if DEBUG
    private func debugKeysConfigured() -> Bool {
        let pexels = (Bundle.main.object(forInfoDictionaryKey: "PEXELS_API_KEY") as? String) ?? ""
        return !pexels.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    } // End func debugKeysConfigured

    private func debugKeysLine() -> String {
        debugKeysConfigured() ? "Pexels API key configured." : "Missing PEXELS_API_KEY in Info.plist."
    } // End func debugKeysLine
    #endif
} // End SettingsView
// End SettingsView
