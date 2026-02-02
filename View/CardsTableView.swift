// File: MyTrip5/View/CardsTableView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI
import SwiftData
import Combine

// This shows a table-mode list for iPad / landscape. (Start)
struct CardsTableView: View {
    @Environment(\.modelContext) private var modelContext // End modelContext
    @EnvironmentObject private var services: AppServices // End services

    let cards: [TripCard] // End cards
    @State private var selectedCard: TripCard? // End selectedCard
    @State private var confirmDelete: TripCard? // End confirmDelete

    var body: some View {
        List {
            ForEach(cards) { card in
                Button {
                    selectedCard = card
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.date, style: .date).font(.headline)
                            Text(card.locationName.isEmpty ? "Unnamed location" : card.locationName)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        } // End VStack date/location

                        Spacer()

                        WeatherCompactView(card: card)

                        HStack(spacing: 6) {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                            Text("\(card.pictures.count)")
                                .font(.subheadline)
                                .monospacedDigit()
                                .foregroundStyle(card.pictures.isEmpty ? .secondary : .primary)
                        } // End HStack picture count

                        Button(role: .destructive) {
                            confirmDelete = card
                        } label: {
                            Text("Delete")
                        } // End Button Delete
                        .buttonStyle(.bordered)
                    } // End HStack row
                } // End Button row
                .buttonStyle(.plain)
                .task {
                    do {
                        try await WeatherRefresh.refreshIfNeeded(card: card, services: services)
                        try modelContext.save()
                    } catch {
                        DebugLog.error("Weather refresh failed: \(error)")
                    } // End do/catch
                } // End task
            } // End ForEach
        } // End List
        .alert("Delete card?", isPresented: Binding(
            get: { confirmDelete != nil },
            set: { if !$0 { confirmDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let card = confirmDelete {
                    modelContext.delete(card)
                    try? modelContext.save()
                } // End if let card
                confirmDelete = nil
            } // End Button Delete

            Button("Cancel", role: .cancel) { confirmDelete = nil } // End Button Cancel
        } message: {
            Text("This cannot be undone.")
        } // End alert
        .sheet(item: $selectedCard) { card in
            CardTableDetailSheet(card: card) {
                try? modelContext.save()
            } // End CardTableDetailSheet
        } // End sheet
    } // End body
} // End CardsTableView
