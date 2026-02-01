//
//  TripCard.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/28/26.
//



// File: MyTrip5/Model/TripCard.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation
import SwiftData

// This defines the persistent “Card” model for trips. (Start)
@Model
final class TripCard {
    var id: UUID
    var createdAt: Date
    var updatedAt: Date

    var date: Date
    var locationName: String

    var latitude: Double?
    var longitude: Double?

    var weatherBlob: Data?
    var picturesBlob: Data?
    var primaryPictureIndex: Int

    // Manual overrides (allowed when date < today)
    var manualHiC: Double?
    var manualLowC: Double?
    var manualForecast: String?

    init(date: Date = Date(), locationName: String = "", latitude: Double? = nil, longitude: Double? = nil) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.date = date
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.weatherBlob = nil
        self.picturesBlob = nil
        self.primaryPictureIndex = 0
        self.manualHiC = nil
        self.manualLowC = nil
        self.manualForecast = nil
    }

    var weather: WeatherSnapshot? {
        get { WeatherSnapshot.decode(weatherBlob) }
        set { weatherBlob = newValue?.encode() }
    }

    var pictures: [PictureRef] {
        get { PictureRef.decodeArray(picturesBlob) ?? [] }
        set { picturesBlob = PictureRef.encodeArray(newValue) }
    }

    func touchUpdated() {
        updatedAt = Date()
    }
}
// End TripCard