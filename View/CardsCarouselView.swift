// Copyright 2025 H2so4 Consulting LLC
// File: MyTrip5/View/CardsCarouselView.swift
// This shows cards as a portrait-mode carousel and enforces selection rules. (Start)

import SwiftUI
import SwiftData

struct CardsCarouselView: View {
    @Environment(\.modelContext) private var modelContext // End modelContext
    @EnvironmentObject private var services: AppServices // End services

    let cards: [TripCard] // End cards

    @State private var selection: Int = 0 // End selection
    @State private var selectedCardID: UUID? = nil // End selectedCardID

    private var cardIDs: [UUID] { cards.map { $0.id } } // End cardIDs

    var body: some View {
        if cards.isEmpty {
            ContentUnavailableView(
                "No cards yet",
                systemImage: "calendar.badge.plus",
                description: Text("Tap + to create your first trip card.")
            )
        } else {
            TabView(selection: $selection) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { idx, card in
                    CardView(
                        card: card,
                        canGoPrevCard: idx > 0,
                        canGoNextCard: idx < (cards.count - 1),
                        goPrevCard: {
                            selection = max(0, selection - 1)
                            selectedCardID = cards[selection].id
                        },
                        goNextCard: {
                            selection = min(cards.count - 1, selection + 1)
                            selectedCardID = cards[selection].id
                        }
                    )
                    .padding(.horizontal, 16)
                    .tag(idx)
                    .onAppear {
                        Task { await refreshIfNeeded(card: card) } // End Task
                    } // End onAppear
                } // End ForEach
            } // End TabView
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .onAppear {
                // Initialize selection the first time.
                if selectedCardID == nil, let first = cards.first {
                    selectedCardID = first.id
                    selection = 0
                } // End if init
            } // End onAppear
            .onChange(of: cardIDs) { oldIDs, newIDs in
                // Selection rules:
                // - If one card added -> select it.
                // - If multiple cards added -> select first by date (index 0, because your list is already sorted by date).
                // - If no cards added -> keep current selection by id (edits must not change selection).
                let oldSet = Set(oldIDs)
                let newSet = Set(newIDs)
                let added = Array(newSet.subtracting(oldSet))

                if !added.isEmpty {
                    if added.count > 1 {
                        selectedCardID = cards.first?.id
                        selection = 0
                    } else if let id = added.first, let idx = newIDs.firstIndex(of: id) {
                        selectedCardID = id
                        selection = idx
                    } // End if/else added count
                } else {
                    if let id = selectedCardID, let idx = newIDs.firstIndex(of: id) {
                        selection = idx
                    } else {
                        selectedCardID = cards.first?.id
                        selection = 0
                    } // End if/else keep by id
                } // End if/else added
            } // End onChange cardIDs
            .onChange(of: selection) { _, newValue in
                guard cards.indices.contains(newValue) else { return } // End guard indices
                selectedCardID = cards[newValue].id
                Task { await refreshIfNeeded(card: cards[newValue]) } // End Task
            } // End onChange selection
        } // End if cards.isEmpty
    } // End body

    private func refreshIfNeeded(card: TripCard) async {
        do {
            try await WeatherRefresh.refreshIfNeeded(card: card, services: services)
            try modelContext.save()
        } catch {
            DebugLog.error("Weather refresh failed: \(error)")
        } // End do/catch
    } // End refreshIfNeeded(card:)

} // End CardsCarouselView
// End CardsCarouselView.swift
