// Copyright 2025 H2so4 Consulting LLC
// File: MyTrip5/View/ImportItineraryView.swift
// AI-based itinerary importer using GPT-4o-mini only. (Start)

import SwiftUI
import SwiftData

struct ImportItineraryView: View {

    @Environment(\.dismiss) private var dismiss // End dismiss
    @Environment(\.modelContext) private var modelContext // End modelContext
    @EnvironmentObject private var services: AppServices // End services

    @State private var pastedText: String = "" // End pastedText
    @State private var rows: [ImportRow] = [] // End rows
    @State private var step: ImportStep = .paste // End step

    @State private var startDate: Date = Date() // End startDate
    @State private var isBusy: Bool = false // End isBusy
    @State private var errorMessage: String? = nil // End errorMessage

    var body: some View {
        Form {
            switch step {
            case .paste:
                pasteSection
            case .review:
                reviewSection
            default:
                pasteSection
            } // End switch
        } // End Form
        .navigationTitle("Import Itinerary")
        .toolbar { toolbar } // End toolbar
        .alert("Error",
               isPresented: Binding(get: { errorMessage != nil },
                                    set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { } // End OK
        } message: {
            Text(errorMessage ?? "")
        } // End alert
    } // End body

    private var pasteSection: some View {
        Section {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $pastedText)
                    .frame(minHeight: 620) // Increased size per request

                if pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Paste cruise URL or itinerary text…")
                        .foregroundStyle(.secondary)
                        .padding(.top, 10)
                        .padding(.leading, 6)
                } // End if placeholder
            } // End ZStack
        } // End Section
    } // End pasteSection

    private var reviewSection: some View {
        Section {
            DatePicker("Trip Start Date", selection: $startDate, displayedComponents: [.date])

            if rows.isEmpty {
                Text("No rows found. Go back and try again.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach($rows) { $row in
                    HStack(spacing: 10) {
                        Toggle("", isOn: $row.isSelected).labelsHidden()

                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.locationName)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(row.dateSummary)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        } // End VStack
                        Spacer(minLength: 0)
                    } // End HStack
                    .padding(.vertical, 4)
                } // End ForEach
            } // End if/else
        } // End Section
    } // End reviewSection

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") { dismiss() } // End Cancel
        } // End leading

        ToolbarItem(placement: .topBarTrailing) {
            switch step {
            case .paste:
                Button("Extract") { extract() }
                    .disabled(isBusy || pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            case .review:
                Button("Create Cards") { createCards() }
                    .disabled(isBusy || rows.allSatisfy { !$0.isSelected })
            default:
                Button("Extract") { extract() }
                    .disabled(isBusy || pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } // End switch
        } // End trailing
    } // End toolbar

    private func extract() {
        isBusy = true
        errorMessage = nil

        Task {
            defer { isBusy = false } // End defer

            do {
                let days = try await ItineraryAIImportService.extractDays(
                    from: pastedText,
                    chat: services.openAIChat
                )

                let calendar = Calendar.current // End calendar
                let stops: [ItineraryStop] = days.map { d in
                    let offset = max(0, d.dayNumber - 1)
                    let date = calendar.date(byAdding: .day, value: offset, to: startDate) ?? startDate
                    return ItineraryStop(
                        locationName: d.locationName,
                        startDate: calendar.startOfDay(for: date),
                        endDate: calendar.startOfDay(for: date)
                    )
                } // End stops

                rows = stops.map { ImportRow(stop: $0, isSelected: true) }
                step = .review
            } catch {
                errorMessage = error.localizedDescription
            } // End do/catch
        } // End Task
    } // End extract

    private func createCards() {
        let selectedStops = rows.filter { $0.isSelected }.map { $0.stop }
        guard !selectedStops.isEmpty else { return } // End guard

        Task {
            do {
                try await ItineraryImportService.createCards(
                    stops: selectedStops,
                    services: services,
                    modelContext: modelContext
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            } // End do/catch
        } // End Task
    } // End createCards

} // End ImportItineraryView

// End ImportItineraryView.swift
