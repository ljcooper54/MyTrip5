//
//  CardHeaderSectionView.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/31/26.
//


// File: MyTrip5/View/CardHeaderSectionView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI

struct CardHeaderSectionView: View {
    @Bindable var card: TripCard
    @Binding var showingDatePicker: Bool
    @Binding var showingMap: Bool
    let onChanged: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                TextField("Location Name", text: $card.locationName)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: card.locationName) { _, _ in onChanged() } // End onChange locationName

                Button { showingDatePicker = true } label: {
                    Label(card.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                } // End Button date picker
                .buttonStyle(.bordered)
                .accessibilityLabel("Pick date")
            } // End VStack left

            Spacer()

            Button("[Map]") { showingMap = true }
                .buttonStyle(.bordered)
        } // End HStack header
    } // End body
} // End CardHeaderSectionView