// ============================================================================
// File: MyTrip5/View/SettingsView.swift  (CHANGED)
// ============================================================================

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss // End dismiss
    @EnvironmentObject private var services: AppServices // End services

    var body: some View {
        NavigationStack {
            Form {
                Section("Export") {
                    NavigationLink("Export PDF…") { ExportRangeView(mode: .pdf) } // End NavigationLink Export PDF
                    NavigationLink("Export CSV…") { ExportRangeView(mode: .csv) } // End NavigationLink Export CSV
                } // End Section Export

                Section("Import") {
                    NavigationLink("Import…") { ImportItineraryView() } // End NavigationLink ImportItineraryView
                } // End Section Import

                Section("Units") {
                    Picker("Temperature", selection: $services.settings.temperatureUnit) {
                        ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                            Text(unit == .celsius ? "Celsius" : "Fahrenheit").tag(unit)
                        } // End ForEach units
                    } // End Picker
                    .pickerStyle(.segmented)
                } // End Section Units

                Section("Thanks To") {
                    NavigationLink("Thanks To") { ThanksToView() } // End NavigationLink ThanksToView
                } // End Section Thanks To

                Section("About") {
                    Text("MyTrip (C) 2026 H2so4 Consulting LLC.  All rights reserved.")
                        .font(.callout)
                } // End Section About

                #if DEBUG
                Section("Debug") {
                    Text(BuildConfig.isConfigured ? "API keys configured." : "Missing API keys in Info.plist build settings.")
                        .foregroundStyle(BuildConfig.isConfigured ? .green : .red)
                } // End Section Debug
                #endif
            } // End Form
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() } // End Button Done
                } // End ToolbarItem Done
            } // End toolbar
        } // End NavigationStack
    } // End body
} // End SettingsView
