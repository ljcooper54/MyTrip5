//
//  MyTrip5App.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/28/26.
//


// File: MyTrip5/MyTrip5App.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI
import SwiftData

// This is the app entry point wiring SwiftData + shared services. (Start)
@main
struct MyTrip5App: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: TripCard.self)
        .environmentObject(AppServices.shared)
    }
}
// End MyTrip5App
