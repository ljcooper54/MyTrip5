//
//  CardsTableView.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/28/26.
//


// File: MyTrip5/View/CardsTableView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI
import SwiftData
import Combine

// This shows a table-mode list for iPad / landscape. (Start)
struct CardsTableView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var services: AppServices

    let cards: [TripCard]
    @State private var editingCard: TripCard?
    @State private var confirmDelete: TripCard?

    var body: some View {
        List {
            ForEach(cards) { card in
                Button {
                    editingCard = card
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.date, style: .date).font(.headline)
                            Text(card.locationName.isEmpty ? "Unnamed location" : card.locationName)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        WeatherCompactView(card: card)
                        Image(systemName: card.pictures.isEmpty ? "photo" : "photo.fill")
                            .foregroundStyle(card.pictures.isEmpty ? .secondary : .primary)

                        Button(role: .destructive) {
                            confirmDelete = card
                        } label: {
                            Text("Delete")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .buttonStyle(.plain)
                .task {
                    do {
                        try await WeatherRefresh.refreshIfNeeded(card: card, services: services)
                        try modelContext.save()
                    } catch {
                        DebugLog.error("Weather refresh failed: \(error)")
                    }
                }
            }
        }
        .alert("Delete card?", isPresented: Binding(
            get: { confirmDelete != nil },
            set: { if !$0 { confirmDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let card = confirmDelete {
                    modelContext.delete(card)
                    try? modelContext.save()
                }
                confirmDelete = nil
            }
            Button("Cancel", role: .cancel) { confirmDelete = nil }
        } message: {
            Text("This cannot be undone.")
        }
        .sheet(item: $editingCard) { card in
            AddEditCardSheet(mode: .edit, existing: card)
        }
    }
}
// End CardsTableView
