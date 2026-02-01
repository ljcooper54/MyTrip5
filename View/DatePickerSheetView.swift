//
//  DatePickerSheetView.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/31/26.
//


// File: MyTrip5/View/DatePickerSheetView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI

// This shows a graphical calendar picker and dismisses immediately when the date changes. (Start)
struct DatePickerSheetView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let onPicked: (Date) -> Void

    @State private var date: Date

    init(title: String, initialDate: Date, onPicked: @escaping (Date) -> Void) {
        self.title = title
        self.onPicked = onPicked
        _date = State(initialValue: initialDate)
    } // End init

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                DatePicker(
                    title,
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding(.horizontal, 10)
                .onChange(of: date) { _, newValue in
                    onPicked(newValue)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        dismiss()
                    } // End asyncAfter
                } // End onChange

                Text("Tap a day to select and close.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            } // End VStack
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                } // End ToolbarItem
            } // End toolbar
        } // End NavigationStack
    } // End body
} // End DatePickerSheetView
// End DatePickerSheetView.swift