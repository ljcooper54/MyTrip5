// File: MyTrip5/View/PrintRangeView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI
import SwiftData

// This selects a date range + layout, generates a PDF, and shares it. (Start)
struct PrintRangeView: View {
    @Environment(\.dismiss) private var dismiss // End dismiss
    @EnvironmentObject private var services: AppServices // End services

    @Query(sort: \TripCard.date, order: .forward) private var cards: [TripCard] // End cards

    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date() // End startDate
    @State private var endDate: Date = Date() // End endDate
    @State private var layout: PrintLayout = .table // End layout

    @State private var isWorking = false // End isWorking
    @State private var errorText: String? = nil // End errorText
    @State private var shareItem: ShareItem? = nil // End shareItem

    var body: some View {
        Form {
            Section("Date Range") {
                DatePicker("Start", selection: $startDate, displayedComponents: .date) // End DatePicker Start
                DatePicker("End", selection: $endDate, displayedComponents: .date) // End DatePicker End
            } // End Section Date Range

            Section("Layout") {
                Picker("Layout", selection: $layout) {
                    Text("Table").tag(PrintLayout.table)
                    Text("Cards").tag(PrintLayout.cards)
                } // End Picker
                .pickerStyle(.segmented)

                Text(summaryText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } // End Section Layout

            Section {
                Button {
                    Task { await generate() } // End Task generate
                } label: {
                    if isWorking {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Generating PDF…")
                        } // End HStack progress
                    } else {
                        Text("Create PDF")
                    } // End if/else isWorking
                } // End Button Create PDF
                .disabled(isWorking || filteredCards.isEmpty)
            } // End Section Create

            if let errorText {
                Section("Error") {
                    Text(errorText).foregroundStyle(.red)
                } // End Section Error
            } // End if errorText
        } // End Form (long)
        .navigationTitle("Print")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() } // End Button Done
            } // End ToolbarItem Done
        } // End toolbar
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.url]) // End ShareSheet
        } // End sheet
    } // End body

    private var filteredCards: [TripCard] {
        let s = Calendar.current.startOfDay(for: startDate)
        let e = Calendar.current.startOfDay(for: endDate)
        let lo = min(s, e)
        let hi = max(s, e)

        return cards.filter { card in
            let d = Calendar.current.startOfDay(for: card.date)
            return d >= lo && d <= hi
        } // End filter
    } // End filteredCards

    private var summaryText: String {
        let count = filteredCards.count
        let pics = filteredCards.reduce(0) { $0 + $1.pictures.count }
        return "\(count) card\(count == 1 ? "" : "s"), \(pics) picture\(pics == 1 ? "" : "s")"
    } // End summaryText

    private func generate() async {
        isWorking = true
        errorText = nil
        defer { isWorking = false } // End defer isWorking

        do {
            let unit = services.settings.temperatureUnit
            let url: URL

            switch layout {
            case .table:
                url = try await PDFPrintService.makeTablePDF(cards: filteredCards, temperatureUnit: unit)
            case .cards:
                url = try await PDFPrintService.makeCardsPDF(cards: filteredCards, temperatureUnit: unit)
            } // End switch layout

            shareItem = ShareItem(url: url)
        } catch {
            errorText = error.localizedDescription
        } // End do/catch generate
    } // End func generate (long)
} // End PrintRangeView

enum PrintLayout: String, CaseIterable, Identifiable {
    case table // End table
    case cards // End cards
    var id: String { rawValue } // End id
} // End PrintLayout

private struct ShareItem: Identifiable {
    let id = UUID() // End id
    let url: URL // End url
} // End ShareItem
