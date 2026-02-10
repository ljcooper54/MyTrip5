// Copyright 2025 H2so4 Consulting LLC
//
//  ItineraryStop.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 2/2/26.
//

// ============================================================================
// File: MyTrip5/Utilities/ItineraryStop.swift
// ============================================================================

import Foundation

/// A parsed stop (location + date range) used by itinerary import workflows.
struct ItineraryStop: Identifiable {
    let id = UUID() // End id
    let locationName: String // End locationName
    let startDate: Date // End startDate
    let endDate: Date // End endDate
} // End struct ItineraryStop

/// Row wrapper for the import review UI.
struct ImportRow: Identifiable {
    let id = UUID() // End id
    let stop: ItineraryStop // End stop
    var isSelected: Bool // End isSelected

    var locationName: String { stop.locationName } // End locationName

    var dateSummary: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        if Calendar.current.isDate(stop.startDate, inSameDayAs: stop.endDate) {
            return f.string(from: stop.startDate)
        } // End if same day
        return "\(f.string(from: stop.startDate)) → \(f.string(from: stop.endDate))"
    } // End dateSummary
} // End struct ImportRow

/// Steps for the itinerary import UI.
enum ImportStep {
    case paste // End paste
    case cruiseStartDate // End cruiseStartDate
    case review // End review
} // End enum ImportStep
