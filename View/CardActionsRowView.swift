//
//  CardActionsRowView.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/31/26.
//


// File: MyTrip5/View/CardActionsRowView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI

struct CardActionsRowView: View {
    let onPickFromMap: () -> Void
    let onRefreshWeather: () -> Void

    var body: some View {
        HStack {
            Button("[Pick from Map]") { onPickFromMap() }
                .buttonStyle(.bordered)

            Spacer()

            Button("Refresh Weather") { onRefreshWeather() }
                .buttonStyle(.bordered)
        } // End HStack actions row
    } // End body
} // End CardActionsRowView