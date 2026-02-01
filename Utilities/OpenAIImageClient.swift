// File: MyTrip5/Utilities/OpenAIImageClient.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation

// This calls the Pexels API to fetch an iconic travel photo URL and records attribution. (Start)
final class OpenAIImageClient {
    private let session: URLSession // End session

    init() {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest = 25
        cfg.timeoutIntervalForResource = 25
        self.session = URLSession(configuration: cfg)
    } // End init

    func generateIconicImage(locationName: String) async throws -> URL {
        let apiKey = (Bundle.main.object(forInfoDictionaryKey: "PEXELS_API_KEY") as? String) ?? ""
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw NSError(domain: "Pexels", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing PEXELS_API_KEY"])
        } // End guard apiKey

        let query = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            throw NSError(domain: "Pexels", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing location name"])
        } // End guard query

        var comps = URLComponents(string: "https://api.pexels.com/v1/search")!
        comps.queryItems = [
            .init(name: "query", value: "iconic landmark photo \(query)"),
            .init(name: "per_page", value: "1"),
            .init(name: "orientation", value: "landscape"),
            .init(name: "size", value: "large")
        ]
        let url = comps.url! // End url

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(trimmed, forHTTPHeaderField: "Authorization")

        #if DEBUG
        DebugLog.api("Pexels GET \(url.absoluteString)")
        #endif

        let (data, resp) = try await session.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1

        #if DEBUG
        DebugLog.api("Pexels status \(code)\n\(String(data: data, encoding: .utf8) ?? "<binary>")")
        #endif

        guard (200...299).contains(code) else {
            throw NSError(domain: "Pexels", code: code, userInfo: [NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? "HTTP \(code)"])
        } // End guard status

        let decoded = try JSONDecoder().decode(PexelsSearchResponse.self, from: data)
        guard let photo = decoded.photos.first else {
            throw NSError(domain: "Pexels", code: 404, userInfo: [NSLocalizedDescriptionKey: "No photo found for \(query)"])
        } // End guard photo exists

        guard let imageURL = photo.src.bestURL() else {
            throw NSError(domain: "Pexels", code: 422, userInfo: [NSLocalizedDescriptionKey: "No usable image URL returned"])
        } // End guard imageURL exists

        if let pageURL = URL(string: photo.url) {
            AttributionStore.add(
                provider: "Pexels",
                photographer: photo.photographer,
                pageURL: pageURL,
                imageURL: imageURL
            )
        } // End if pageURL parsable

        return imageURL
    } // End func generateIconicImage (long)
} // End OpenAIImageClient

private struct PexelsSearchResponse: Decodable {
    let photos: [Photo] // End photos

    struct Photo: Decodable {
        let id: Int // End id
        let url: String // End url
        let photographer: String // End photographer
        let src: Src // End src
    } // End Photo

    struct Src: Decodable {
        let original: String? // End original
        let large2x: String? // End large2x
        let large: String? // End large
        let medium: String? // End medium

        func bestURL() -> URL? {
            let candidates = [large2x, large, medium, original].compactMap { $0 } // End candidates
            for c in candidates {
                if let u = URL(string: c) { return u } // End if URL(string:)
            } // End for candidates
            return nil
        } // End func bestURL
    } // End Src
} // End PexelsSearchResponse
// End OpenAIImageClient
