// ===== File: MyTrip5/View/CardsCarouselView.swift =====
// File: MyTrip5/View/CardsCarouselView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI
import SwiftData

// This shows cards as a portrait-mode carousel with card-nav buttons on each card. (Start)
struct CardsCarouselView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var services: AppServices

    let cards: [TripCard]
    @State private var selection: Int = 0

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
                        goPrevCard: { selection = max(0, selection - 1) },
                        goNextCard: { selection = min(cards.count - 1, selection + 1) }
                    )
                    .padding(.horizontal, 16)
                    .tag(idx)
                    .onAppear {
                        Task { await refreshIfNeeded(card: card) } // End Task
                    } // End onAppear
                } // End ForEach
            } // End TabView
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .onChange(of: cards.count) { oldValue, newValue in
                if newValue > oldValue {
                    selection = max(0, newValue - 1)
                } // End if added
            } // End onChange cards.count
            .onChange(of: selection) { _, newValue in
                guard cards.indices.contains(newValue) else { return } // End guard indices
                Task { await refreshIfNeeded(card: cards[newValue]) } // End Task
            } // End onChange
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
