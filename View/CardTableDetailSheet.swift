//
//  CardTableDetailSheet.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 2/2/26.
//


// File: MyTrip5/View/CardTableDetailSheet.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI

// This sheet shows card details in table mode, with editable manual weather for past dates. (Start)
struct CardTableDetailSheet: View {
    @Environment(\.dismiss) private var dismiss // End dismiss
    @EnvironmentObject private var services: AppServices // End services

    @Bindable var card: TripCard // End card
    let onChanged: () -> Void // End onChanged

    var body: some View {
        NavigationStack {
            Form {
                Section("Card") {
                    Text(card.locationName.isEmpty ? "Unnamed location" : card.locationName)
                    Text(card.date, style: .date)
                    HStack {
                        Image(systemName: "photo")
                        Text("\(card.pictures.count) picture\(card.pictures.count == 1 ? "" : "s")")
                    } // End HStack picture count
                } // End Section Card

                Section("Weather") {
                    WeatherCompactView(card: card)

                    if isPastDate {
                        WeatherManualEntryView(card: card, unit: services.settings.temperatureUnit, onChanged: onChanged)
                    } // End if isPastDate
                } // End Section Weather
            } // End Form
            .navigationTitle("Details")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() } // End Button Done
                } // End ToolbarItem Done
            } // End toolbar
        } // End NavigationStack
    } // End body

    private var isPastDate: Bool {
        card.date < Calendar.current.startOfDay(for: Date())
    } // End isPastDate
} // End CardTableDetailSheet