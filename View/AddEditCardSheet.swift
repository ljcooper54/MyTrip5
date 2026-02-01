// ===== File: MyTrip5/View/AddEditCardSheet.swift =====
//
//  AddEditCardSheet.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/28/26.
//

// File: MyTrip5/View/AddEditCardSheet.swift
// Copyright H2so4 Consulting LLC, 2026

// Copyright H2so4 Consulting LLC, 2026

import SwiftUI
import SwiftData
import MapKit
import CoreLocation

// This provides the add/edit dialog for table mode, with Add/Cancel. (Start)
struct AddEditCardSheet: View {
    enum Mode { case add, edit }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var services: AppServices

    let mode: Mode
    let existing: TripCard?

    @State private var date: Date = Date()
    @State private var locationName: String = ""
    @State private var lat: Double?
    @State private var lon: Double?

    @State private var showingMap = false
    @State private var showingDatePicker = false // End showingDatePicker
    @State private var isBusy = false // End isBusy
    @State private var busyMessage: String = "Working…" // End busyMessage
    @State private var errorMessage: String? // End errorMessage

    var body: some View {
        NavigationStack {
            Form {
                Section("Card") {
                    TextField("Location Name", text: $locationName)

                    Button {
                        showingDatePicker = true
                    } label: {
                        Label(date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    } // End Button Date
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Pick date")

                    HStack {
                        Text("Map Location")
                        Spacer()
                        Text(lat != nil && lon != nil ? "Set" : "None")
                            .foregroundStyle(.secondary)
                    }

                    Button("[Pick from Map]") { showingMap = true }
                }
            }
            .navigationTitle(mode == .add ? "Add Card" : "Edit Card")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(mode == .add ? "Add" : "Save") {
                        Task { await commit() }
                    }
                    .disabled(locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .overlay {
                if isBusy {
                    BusyOverlayView(message: busyMessage)
                } // End if isBusy
            } // End overlay
            .alert("Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            } // End alert Error
            .onAppear {
                if let existing {
                    date = existing.date
                    locationName = existing.locationName
                    lat = existing.latitude
                    lon = existing.longitude
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                CalendarPickerSheetView(title: "Date", date: $date) { _ in
                } // End CalendarPickerSheetView
            } // End sheet showingDatePicker
            .sheet(isPresented: $showingMap) {
                MapPickerView(
                    initialCenter: initialCenter(),
                    initialSpan: initialSpan()
                ) { selection in
                    lat = selection.center.latitude
                    lon = selection.center.longitude
                    services.settings.lastMapCenterLat = selection.center.latitude
                    services.settings.lastMapCenterLon = selection.center.longitude
                    services.settings.lastMapSpanLatDelta = selection.span.latitudeDelta
                    services.settings.lastMapSpanLonDelta = selection.span.longitudeDelta

                    Task {
                        if locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            if let resolved = try? await services.geocoder.reverseGeocode(coord: selection.center) {
                                locationName = resolved
                            }
                        }
                    }
                }
            }
        }
    }

    private func initialCenter() -> CLLocationCoordinate2D {
        if let lat = services.settings.lastMapCenterLat, let lon = services.settings.lastMapCenterLon {
            return .init(latitude: lat, longitude: lon)
        }
        if let lat, let lon { return .init(latitude: lat, longitude: lon) }
        return .init(latitude: 37.7749, longitude: -122.4194)
    }

    private func initialSpan() -> MKCoordinateSpan {
        if let dLat = services.settings.lastMapSpanLatDelta, let dLon = services.settings.lastMapSpanLonDelta {
            return .init(latitudeDelta: dLat, longitudeDelta: dLon)
        }
        return .init(latitudeDelta: 0.3, longitudeDelta: 0.3)
    }

    private func commit() async {
        isBusy = true
        busyMessage = "Saving…"
        defer { isBusy = false } // End defer
        // This writes changes and triggers weather lookup when applicable. (Start)
        let card: TripCard
        if let existing {
            card = existing
        } else {
            card = TripCard()
            modelContext.insert(card)
        }

        card.date = date
        card.locationName = locationName
        card.latitude = lat
        card.longitude = lon
        card.touchUpdated()

        do {
            busyMessage = "Refreshing weather…"
            try await WeatherRefresh.refreshIfNeeded(card: card, services: services, force: true)
            try modelContext.save()
        } catch {
            DebugLog.error("Commit weather refresh failed: \(error)")
            errorMessage = error.localizedDescription
            try? modelContext.save()
        }

        dismiss()
        // End commit
    }
} // End AddEditCardSheet
