// Copyright 2025 H2so4 Consulting LLC
// File: MyTrip5/Utilities/ItineraryAIImportService.swift
// Uses GPT-4o-mini to extract structured itinerary days from pasted text or URL. (Start)

import Foundation

enum ItineraryAIImportError: Error, LocalizedError {
    case emptyResponse // End emptyResponse
    case invalidJSON(String) // End invalidJSON

    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "AI returned empty response."
        case .invalidJSON(let details):
            return "AI returned invalid JSON. \(details)"
        } // End switch
    } // End errorDescription
} // End enum ItineraryAIImportError

struct AIItineraryDay: Codable {
    let dayNumber: Int // End dayNumber
    let locationName: String // End locationName
    let description: String // End description
} // End struct AIItineraryDay

enum ItineraryAIImportService {

    static func extractDays(from pastedInput: String, chat: OpenAIChatClient) async throws -> [AIItineraryDay] {
        let input = pastedInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return [] } // End guard input

        let system = "You extract travel itineraries and return strict JSON only." // End system

        let user = """
You may be given:
- A cruise/travel URL
- Raw itinerary text
- HTML snippets
- Mixed content

If it is a URL, assume you can read the page and extract itinerary days.

Return ONLY valid JSON in this exact format:

[
  { "dayNumber": 1, "locationName": "Hanoi, Vietnam", "description": "..." }
]

Rules:
- dayNumber must be sequential starting at 1
- locationName should be a clean city/port name
- description must be 1–4 concise sentences
- JSON only (no markdown, no commentary)

INPUT:
\(input)
""" // End user

        let response = try await chat.chat(system: system, user: user)
        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ItineraryAIImportError.emptyResponse } // End guard trimmed

        guard let data = trimmed.data(using: .utf8) else {
            throw ItineraryAIImportError.invalidJSON("Could not UTF-8 encode response.")
        } // End guard data

        do {
            let days = try JSONDecoder().decode([AIItineraryDay].self, from: data)
            return days.sorted { $0.dayNumber < $1.dayNumber }
        } catch {
            throw ItineraryAIImportError.invalidJSON("Decode failed: \(error.localizedDescription)")
        } // End do/catch
    } // End func extractDays(from:chat:)

} // End enum ItineraryAIImportService

// End ItineraryAIImportService.swift
