// File: MyTrip5/View/MapPickerView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI
import MapKit
import CoreLocation

// This allows selecting a map center via crosshairs and returns chosen center+span. (Start)
struct MapSelection {
    var center: CLLocationCoordinate2D
    var span: MKCoordinateSpan
} // End MapSelection

// This presents a map with crosshairs for selecting a location. (Start)
struct MapPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var region: MKCoordinateRegion
    @State private var position: MapCameraPosition

    let onSelect: (MapSelection) -> Void

    init(initialCenter: CLLocationCoordinate2D, initialSpan: MKCoordinateSpan, onSelect: @escaping (MapSelection) -> Void) {
        let r = MKCoordinateRegion(center: initialCenter, span: initialSpan)
        _region = State(initialValue: r)
        _position = State(initialValue: .region(r))
        self.onSelect = onSelect
    } // End init(initialCenter:initialSpan:onSelect:)

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position) { } // End Map(position:)
                    .onMapCameraChange { ctx in
                        region = ctx.region
                    } // End onMapCameraChange
                    .ignoresSafeArea()

                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .padding(10)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } // End ZStack
            .navigationTitle("Pick Location")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() } // End Button Cancel
                } // End ToolbarItem leading
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Select") {
                        onSelect(.init(center: region.center, span: region.span))
                        dismiss()
                    } // End Button Select
                } // End ToolbarItem trailing
            } // End toolbar
        } // End NavigationStack
    } // End body

} // End MapPickerView
// End MapPickerView.swift
