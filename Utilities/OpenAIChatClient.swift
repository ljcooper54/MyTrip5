// Copyright 2025 H2so4 Consulting LLC
// File: MyTrip5/Utilities/OpenAIChatClient.swift
// Minimal OpenAI chat client via /v1/responses using gpt-4o-mini only. (Start)

import Foundation

final class OpenAIChatClient {

    private let session: URLSession // End session

    init() {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest = 60
        cfg.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: cfg)
    } // End init

    /// Sends a system+user prompt to OpenAI Responses API using gpt-4o-mini and returns plain text. (Start)
    func chat(system: String, user: String) async throws -> String {
        let apiKey = infoPlistKey("OPENAI_API_KEY")
        guard !apiKey.isEmpty else {
            throw NSError(domain: "OpenAI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing OPENAI_API_KEY"])
        } // End guard apiKey

        let endpoint = URL(string: "https://api.openai.com/v1/responses")!
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.timeoutInterval = 60
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let input = """
SYSTEM:
\(system)

USER:
\(user)
"""

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "input": input
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await session.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
        guard (200...299).contains(code) else {
            throw NSError(
                domain: "OpenAI",
                code: code,
                userInfo: [NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? "HTTP \(code)"]
            )
        } // End guard status

        let decoded = try JSONDecoder().decode(OpenAIResponsesResponse.self, from: data)
        guard let text = decoded.outputText?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            throw NSError(domain: "OpenAI", code: 2, userInfo: [NSLocalizedDescriptionKey: "No text returned"])
        } // End guard text

        return text
    } // End func chat(system:user:)

    /// Parses pasted itinerary text or a URL into stops (JSON payloads) using gpt-4o-mini. (Start)
    func parseItinerary(text: String, today: Date) async throws -> [ItineraryStopPayload] {
        let isoToday = Self.isoDate(today) // End isoToday

        let system = "You extract travel itineraries into strict JSON only." // End system

        let user = """
You will receive either:
- A travel/cruise URL, OR
- Itinerary text (possibly partial), OR
- HTML snippets.

If it is a URL, assume you can read the page and extract itinerary days.

Return ONLY valid JSON as an array of objects with EXACTLY these keys:
[
  { "locationName": "Hanoi, Vietnam", "startDate": "2026-08-10", "endDate": "2026-08-10" }
]

Rules:
- JSON only. No markdown. No commentary.
- Dates MUST be ISO yyyy-MM-dd.
- Use the provided TODAY to resolve relative dates if needed.
- If the input only has Day 1 / Day 2 / ... with no calendar dates, infer sequential dates starting at TODAY (or the earliest explicit departure date if present).
- endDate may equal startDate; multi-day stays should have endDate >= startDate.
- locationName should be a clean city/port name (no "Day 3 —" prefix).

TODAY: \(isoToday)

INPUT:
\(text)
""" // End user

        let raw = try await chat(system: system, user: user) // End raw
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = trimmed.data(using: .utf8) else {
            throw NSError(domain: "OpenAI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not UTF-8 encode model response."])
        } // End guard data

        do {
            return try JSONDecoder().decode([ItineraryStopPayload].self, from: data)
        } catch {
            throw NSError(
                domain: "OpenAI",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "Invalid itinerary JSON: \(error.localizedDescription)\n\nRaw:\n\(trimmed)"]
            )
        } // End do/catch
    } // End func parseItinerary(text:today:)

    private func infoPlistKey(_ name: String) -> String {
        let raw = (Bundle.main.object(forInfoDictionaryKey: name) as? String) ?? ""
        return raw.trimmingCharacters(in: .whitespacesAndNewlines)
    } // End func infoPlistKey(_:)

    private static func isoDate(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    } // End func isoDate(_:)

} // End OpenAIChatClient

private struct OpenAIResponsesResponse: Decodable {
    let output: [Output] // End output

    var outputText: String? {
        for o in output {
            if o.type == "message" {
                for c in o.content ?? [] {
                    if c.type == "output_text", let t = c.text {
                        return t
                    } // End if output_text
                } // End for content
            } // End if message
        } // End for output
        return nil
    } // End outputText

    struct Output: Decodable {
        let type: String // End type
        let content: [Content]? // End content
    } // End Output

    struct Content: Decodable {
        let type: String // End type
        let text: String? // End text
    } // End Content
} // End OpenAIResponsesResponse

// End OpenAIChatClient.swift
