// ===== File: MyTrip5/Utilities/OpenWeatherClient.swift =====
//
//  OpenWeatherClient.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/28/26.
//

// File: MyTrip5/Utilities/OpenWeatherClient.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation
import CoreLocation

// This calls OpenWeather One Call 3.0 endpoints and decodes results. (Start)
final class OpenWeatherClient {
    private let session: URLSession = .shared

    func fetchWeatherSnapshot(
        for date: Date,
        coord: CLLocationCoordinate2D,
        timeoutSeconds: TimeInterval = 10
    ) async throws -> WeatherSnapshot {
        let daysAhead = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: date)
        ).day ?? 9999

        if daysAhead < 0 {
            return WeatherSnapshot.noWeather()
        }

        if daysAhead <= 7 {
            return try await fetchOneCallDaily(for: date, coord: coord, timeoutSeconds: timeoutSeconds)
        }

        if daysAhead <= 14 {
            return try await fetchDaySummary(for: date, coord: coord, timeoutSeconds: timeoutSeconds)
        }

        return WeatherSnapshot.noWeather()
    } // End fetchWeatherSnapshot(for:coord:timeoutSeconds:)

    private func fetchOneCallDaily(
        for date: Date,
        coord: CLLocationCoordinate2D,
        timeoutSeconds: TimeInterval
    ) async throws -> WeatherSnapshot {
        guard !BuildConfig.openWeatherKey.isEmpty else {
            throw NSError(domain: "OpenWeather", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing OPENWEATHER_API_KEY"])
        }

        var comps = URLComponents(string: "https://api.openweathermap.org/data/3.0/onecall")!
        comps.queryItems = [
            .init(name: "lat", value: "\(coord.latitude)"),
            .init(name: "lon", value: "\(coord.longitude)"),
            .init(name: "exclude", value: "minutely,hourly,alerts,current"),
            .init(name: "units", value: "metric"),
            .init(name: "appid", value: BuildConfig.openWeatherKey)
        ]
        let url = comps.url!

        let (data, _) = try await performGET(url: url, timeoutSeconds: timeoutSeconds)
        let decoded = try JSONDecoder().decode(OneCallDailyResponse.self, from: data)
        let day = Calendar.current.startOfDay(for: date)

        // Pick closest daily entry by local calendar day using dt timestamp.
        let best = decoded.daily
            .map { ($0, Date(timeIntervalSince1970: TimeInterval($0.dt))) }
            .min { abs($0.1.timeIntervalSince(day)) < abs($1.1.timeIntervalSince(day)) }?.0

        guard let best else { return WeatherSnapshot.noWeather() }

        let forecast = best.weather.first?.main ?? best.weather.first?.description ?? "Forecast"
        return WeatherSnapshot(
            hiC: best.temp.max,
            lowC: best.temp.min,
            forecast: forecast,
            rainChance: best.pop,
            snowChance: nil,
            updatedAt: Date(),
            source: .oneCallDaily
        )
    } // End fetchOneCallDaily(for:coord:timeoutSeconds:)

    private func fetchDaySummary(
        for date: Date,
        coord: CLLocationCoordinate2D,
        timeoutSeconds: TimeInterval
    ) async throws -> WeatherSnapshot {
        guard !BuildConfig.openWeatherKey.isEmpty else {
            throw NSError(domain: "OpenWeather", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing OPENWEATHER_API_KEY"])
        }

        let df = DateFormatter()
        df.calendar = .current
        df.timeZone = .current
        df.dateFormat = "yyyy-MM-dd"

        var comps = URLComponents(string: "https://api.openweathermap.org/data/3.0/onecall/day_summary")!
        comps.queryItems = [
            .init(name: "lat", value: "\(coord.latitude)"),
            .init(name: "lon", value: "\(coord.longitude)"),
            .init(name: "date", value: df.string(from: date)),
            .init(name: "units", value: "metric"),
            .init(name: "appid", value: BuildConfig.openWeatherKey)
        ]
        let url = comps.url!

        let (data, _) = try await performGET(url: url, timeoutSeconds: timeoutSeconds)
        let decoded = try JSONDecoder().decode(DaySummaryResponse.self, from: data)

        return WeatherSnapshot(
            hiC: decoded.temperature.max,
            lowC: decoded.temperature.min,
            forecast: "Forecast unavailable",
            rainChance: nil,
            snowChance: nil,
            updatedAt: Date(),
            source: .daySummary
        )
    } // End fetchDaySummary(for:coord:timeoutSeconds:)

    private func performGET(url: URL, timeoutSeconds: TimeInterval) async throws -> (Data, HTTPURLResponse) {
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = timeoutSeconds

        DebugLog.api("OpenWeather GET \(url.absoluteString)")
        let (data, resp) = try await session.data(for: req)

        guard let http = resp as? HTTPURLResponse else {
            throw NSError(domain: "OpenWeather", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }

        DebugLog.api("OpenWeather status \(http.statusCode)\n\(String(data: data, encoding: .utf8) ?? "<binary>")")

        guard (200...299).contains(http.statusCode) else {
            let text = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw NSError(domain: "OpenWeather", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: text])
        }

        return (data, http)
    } // End performGET(url:timeoutSeconds:)
} // End OpenWeatherClient

// This decodes the /onecall daily subset. (Start)
private struct OneCallDailyResponse: Decodable {
    var daily: [Daily]

    struct Daily: Decodable {
        var dt: Int
        var temp: Temp
        var weather: [Weather]
        var pop: Double?

        struct Temp: Decodable {
            var min: Double?
            var max: Double?
        }

        struct Weather: Decodable {
            var main: String?
            var description: String?
        }
    }
} // End OneCallDailyResponse
// End OneCallDailyResponse

// This decodes the /day_summary endpoint. (Start)
private struct DaySummaryResponse: Decodable {
    var temperature: Temperature

    struct Temperature: Decodable {
        var min: Double?
        var max: Double?
    }
} // End DaySummaryResponse
// End DaySummaryResponse
// End OpenWeatherClient
