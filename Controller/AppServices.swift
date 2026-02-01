//
//  AppServices.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/28/26.
//


// File: MyTrip5/Controller/AppServices.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation
import SwiftUI
import CoreLocation
import Combine

// This provides shared settings + API clients for the app. (Start)
@MainActor
final class AppServices: ObservableObject {
    static let shared = AppServices()

    @Published var settings = AppSettings()

    let openWeather = OpenWeatherClient()
    let openAIImages = OpenAIImageClient()
    let geocoder = GeocoderService()

    private init() {}
}
// End AppServices
