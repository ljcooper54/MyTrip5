// =======================================
// File: MyTrip5/View/CardHeaderRowView.swift   (NEW)
// =======================================

import SwiftUI

struct CardHeaderRowView: View {
    @Bindable var card: TripCard // End card
    let onShowMap: () -> Void // End onShowMap
    let onChanged: () -> Void // End onChanged

    var body: some View {
        HStack {
            TextField("Location Name", text: $card.locationName)
                .textFieldStyle(.roundedBorder)
                .onChange(of: card.locationName) { _, _ in
                    card.touchUpdated()
                    onChanged()
                } // End onChange locationName

            DatePicker("", selection: $card.date, displayedComponents: .date)
                .labelsHidden()
                .onChange(of: card.date) { _, _ in
                    card.touchUpdated()
                    onChanged()
                } // End onChange date

            Button("[Map]") { onShowMap() } // End Button Map
                .buttonStyle(.bordered)
        } // End HStack header
    } // End body
} // End CardHeaderRowView
