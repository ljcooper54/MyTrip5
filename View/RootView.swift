// File: MyTrip5/View/RootView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI
import SwiftData

// This renders the root UI, switching between carousel and table layouts. (Start)
struct RootView: View {
    @Environment(\.horizontalSizeClass) private var hSize // End hSize
    @Environment(\.verticalSizeClass) private var vSize // End vSize
    @Environment(\.modelContext) private var modelContext // End modelContext
    @EnvironmentObject private var services: AppServices // End services

    @Query(sort: [
        SortDescriptor(\TripCard.date, order: .forward),
        SortDescriptor(\TripCard.locationName, order: .forward)
    ]) private var cards: [TripCard] // End cards

    @State private var showingSettings = false // End showingSettings
    @State private var showingAddSheet = false // End showingAddSheet

    var body: some View {
        NavigationStack {
            Group {
                if isTableMode {
                    CardsTableView(cards: cards)
                } else {
                    CardsCarouselView(cards: cards)
                } // End if isTableMode
            } // End Group
            .navigationTitle("MyTrip")
            .navigationBarTitleDisplayMode(.inline) // End navigationBarTitleDisplayMode
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    } // End Button
                } // End ToolbarItem leading

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    } // End Button
                } // End ToolbarItem trailing
            } // End toolbar
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            } // End sheet settings
            .sheet(isPresented: $showingAddSheet) {
                AddEditCardSheet(mode: .add, existing: nil)
            } // End sheet add
            .onAppear {
                services.settings = AppSettings.load()
            } // End onAppear
            .onChange(of: services.settings) { _, newValue in
                newValue.save()
            } // End onChange
        } // End NavigationStack
        .dynamicTypeSize(.small ... .xxLarge) // End dynamicTypeSize
    } // End body

    private var isTableMode: Bool {
        if UIDevice.current.userInterfaceIdiom == .pad { return true } // End if iPad
        return hSize == .regular || vSize == .compact // End return
    } // End isTableMode
} // End RootView
// End RootView.swift
