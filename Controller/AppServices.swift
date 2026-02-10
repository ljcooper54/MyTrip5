// Copyright 2025 H2so4 Consulting LLC
// File: MyTrip5/Controller/AppServices.swift
// This provides shared settings + API clients for the app. (Start)

import Foundation
import SwiftUI
import CoreLocation
import Combine

@MainActor
final class AppServices: ObservableObject {
    static let shared = AppServices() // End shared

    @Published var settings = AppSettings() // End settings

    let openWeather = OpenWeatherClient() // End openWeather
    let openAIImages = OpenAIImageClient() // End openAIImages
    let openAIChat = OpenAIChatClient() // End openAIChat
    let geocoder = GeocoderService() // End geocoder

    private init() {} // End init
} // End AppServices

// End AppServices.swift
