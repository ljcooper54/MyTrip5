//
//  ItineraryParseService.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 2/2/26.
//


// ============================================================================
// File: MyTrip5/Utilities/ItineraryParseService.swift  (NEW)
// ============================================================================

import Foundation

enum ItineraryParseService {
    static func parse(text: String, today: Date) async throws -> [ItineraryStop] {
        let client = OpenAIChatClient() // End client
        let payloads = try await client.parseItinerary(text: text, today: today)
        return payloads.compactMap { $0.toStop() }
    } // End func parse (long)
} // End enum ItineraryParseService

struct ItineraryStopPayload: Decodable {
    let locationName: String // End locationName
    let startDate: String // End startDate
    let endDate: String // End endDate

    func toStop() -> ItineraryStop? {
        let name = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return nil } // End guard name

        guard let s = DateParsing.parseYYYYMMDD(startDate),
              let e = DateParsing.parseYYYYMMDD(endDate) else { return nil } // End guard dates

        return ItineraryStop(locationName: name, startDate: s, endDate: e)
    } // End func toStop
} // End struct ItineraryStopPayload

enum DateParsing {
    static func parseYYYYMMDD(_ s: String) -> Date? {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.count == 10 else { return nil } // End guard length

        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: t)
    } // End func parseYYYYMMDD
} // End enum DateParsing

