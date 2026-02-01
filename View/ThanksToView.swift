//
//  ThanksToView.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/31/26.
//


// File: MyTrip5/View/ThanksToView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI

struct ThanksToView: View {
    @Environment(\.dismiss) private var dismiss // End dismiss
    @State private var entries: [AttributionStore.Entry] = [] // End entries

    var body: some View {
        NavigationStack {
            List {
                Section("Photo Provider") {
                    Text("Photos are provided by Pexels.")
                    Link("Pexels License", destination: URL(string: "https://www.pexels.com/license/")!) // End Link
                } // End Section Photo Provider

                Section("Attribution") {
                    if entries.isEmpty {
                        Text("No attributions yet. Add a photo to see credits here.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(entries) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Photo by \(entry.photographer)")
                                    .font(.headline)

                                if let page = URL(string: entry.pageURL) {
                                    Link("View on Pexels", destination: page)
                                } // End if page URL

                                if let image = URL(string: entry.imageURL) {
                                    Link("Direct image URL", destination: image)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                } // End if image URL
                            } // End VStack attribution cell
                            .padding(.vertical, 4)
                        } // End ForEach entries
                    } // End if/else entries.isEmpty
                } // End Section Attribution

                Section {
                    Button(role: .destructive) {
                        AttributionStore.clear()
                        entries = []
                    } label: {
                        Text("Clear Attributions")
                    } // End Button Clear
                } // End Section Clear
            } // End List
            .navigationTitle("Thanks To")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() } // End Button Done
                } // End ToolbarItem Done
            } // End toolbar
            .onAppear {
                entries = AttributionStore.all()
            } // End onAppear
        } // End NavigationStack (long)
    } // End body
} // End ThanksToView