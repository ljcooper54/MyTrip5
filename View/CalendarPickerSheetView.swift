// File: MyTrip5/View/CalendarPickerSheetView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI

// This presents a graphical calendar picker and dismisses immediately on selection. (Start)
struct CalendarPickerSheetView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    @Binding var date: Date
    let onPicked: (Date) -> Void

    var body: some View {
        NavigationStack {
            DatePicker(title, selection: $date, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding(12)
                .onChange(of: date) { _, newValue in
                    onPicked(newValue)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        dismiss()
                    } // End asyncAfter dismiss
                } // End onChange date
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Close") { dismiss() }
                    } // End ToolbarItem close
                } // End toolbar
        } // End NavigationStack calendar sheet
    } // End body
} // End CalendarPickerSheetView
