// ==============================
// File: MyTrip5/View/ExportRangeView.swift  (REPLACE)
// ==============================

import SwiftUI
import SwiftData

struct ExportRangeView: View {
    @Environment(\.dismiss) private var dismiss // End dismiss
    @EnvironmentObject private var services: AppServices // End services

    @Query(sort: \TripCard.date, order: .forward) private var cards: [TripCard] // End cards

    private let mode: ExportMode // End mode

    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date() // End startDate
    @State private var endDate: Date = Date() // End endDate

    @State private var pdfOption: PDFOption = .table // End pdfOption
    @State private var isWorking = false // End isWorking
    @State private var errorText: String? = nil // End errorText
    @State private var shareItem: ShareItem? = nil // End shareItem

    init(mode: ExportMode) {
        self.mode = mode
    } // End init(mode:)

    var body: some View {
        Form {
            Section("Date Range") {
                DatePicker("Start", selection: $startDate, displayedComponents: .date) // End DatePicker Start
                DatePicker("End", selection: $endDate, displayedComponents: .date) // End DatePicker End
            } // End Section Date Range

            Section("Output") {
                if mode == .pdf {
                    Picker("PDF", selection: $pdfOption) {
                        Text("Table").tag(PDFOption.table)
                        Text("Carousel").tag(PDFOption.carousel)
                    } // End Picker
                    .pickerStyle(.segmented)
                } else {
                    HStack {
                        Text("CSV")
                        Spacer()
                        Text("Table View")
                            .foregroundStyle(.secondary)
                    } // End HStack CSV fixed output
                } // End if/else mode == .pdf

                Text(summaryText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } // End Section Output

            Section {
                Button {
                    Task { await runExport() } // End Task runExport
                } label: {
                    if isWorking {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Exporting…")
                        } // End HStack exporting
                    } else {
                        Text(buttonTitle)
                    } // End if/else isWorking
                } // End Button export
                .disabled(isWorking || filteredCards.isEmpty)
            } // End Section Action

            if let errorText {
                Section("Error") {
                    Text(errorText).foregroundStyle(.red)
                } // End Section Error
            } // End if errorText
        } // End Form (long)
        .navigationTitle(mode == .pdf ? "Export PDF" : "Export CSV")
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

    private var buttonTitle: String {
        mode == .pdf ? "Export PDF" : "Export CSV"
    } // End buttonTitle

    private func runExport() async {
        isWorking = true
        errorText = nil
        defer { isWorking = false } // End defer isWorking

        do {
            let unit = services.settings.temperatureUnit
            let url: URL

            switch mode {
            case .csv:
                url = try CSVExportService.makeTableCSV(cards: filteredCards, temperatureUnit: unit)
            case .pdf:
                switch pdfOption {
                case .table:
                    url = try await PDFPrintService.makeTablePDF(cards: filteredCards, temperatureUnit: unit)
                case .carousel:
                    url = try await PDFPrintService.makeCardsPDF(cards: filteredCards, temperatureUnit: unit)
                } // End switch pdfOption
            } // End switch mode

            shareItem = ShareItem(url: url)
        } catch {
            errorText = error.localizedDescription
        } // End do/catch runExport
    } // End func runExport (long)
} // End ExportRangeView

enum ExportMode {
    case pdf // End pdf
    case csv // End csv
} // End ExportMode

private enum PDFOption {
    case table // End table
    case carousel // End carousel
} // End PDFOption

private struct ShareItem: Identifiable {
    let id = UUID() // End id
    let url: URL // End url
} // End ShareItem
