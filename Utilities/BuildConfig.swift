//
//  BuildConfig.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/28/26.
//


// File: MyTrip5/Utilities/BuildConfig.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation

// This reads API keys from Info.plist (backed by xcconfig build settings). (Start)
enum BuildConfig {
    static var openWeatherKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static var openAIKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static var isConfigured: Bool {
        !openWeatherKey.isEmpty && !openAIKey.isEmpty
    }
}
// End BuildConfig
