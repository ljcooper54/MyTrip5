//
//  CardDeleteRowView.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/31/26.
//


// File: MyTrip5/View/CardDeleteRowView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI

struct CardDeleteRowView: View {
    let onDelete: () -> Void

    var body: some View {
        Button(role: .destructive) { onDelete() } label: {
            Text("Delete Card").frame(maxWidth: .infinity)
        } // End Button delete card
        .buttonStyle(.bordered)
    } // End body
} // End CardDeleteRowView