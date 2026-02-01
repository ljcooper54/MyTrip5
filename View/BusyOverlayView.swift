// File: MyTrip5/View/BusyOverlayView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI

struct BusyOverlayView: View {
    let message: String

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.35))
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.8)

                Text(message)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            } // End VStack overlay content
            .padding(18)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 10)
            .padding(.horizontal, 26)
        } // End ZStack BusyOverlayView (long)
        .accessibilityAddTraits(.isModal)
    } // End body
} // End BusyOverlayView
