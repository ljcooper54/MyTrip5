// ==============================
// File: MyTrip5/View/TablePrintRowView.swift
// ==============================

import SwiftUI

// This is a print-friendly row approximating table WYSIWYG. (Start)
struct TablePrintRowView: View {
    let card: TripCard // End card
    let unit: TemperatureUnit // End unit

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(card.date, style: .date)
                .font(.headline)
                .frame(width: 120, alignment: .leading)

            Text(card.locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Unnamed location" : card.locationName)
                .lineLimit(1)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(PDFWeatherStringBuilder.build(card: card, unit: unit))
                .lineLimit(2)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 240, alignment: .leading)

            HStack(spacing: 6) {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
                Text("\(card.pictures.count)")
                    .monospacedDigit()
            } // End HStack picture count
            .frame(width: 70, alignment: .trailing)
        } // End HStack row
        .padding(.vertical, 2)
        .overlay(alignment: .bottom) {
            Divider()
        } // End overlay Divider
    } // End body
} // End struct TablePrintRowView
