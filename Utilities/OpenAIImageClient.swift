// File: MyTrip5/Utilities/OpenAIImageClient.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation

// Provides:
// - Pexels iconic travel photo URL (25s timeouts)
// - OpenAI iconic landmark generation (>=120s timeouts)
// (Start)
final class OpenAIImageClient {
    private let pexelsSession: URLSession // End pexelsSession
    private let openAISession: URLSession // End openAISession

    init() {
        let pCfg = URLSessionConfiguration.ephemeral
        pCfg.timeoutIntervalForRequest = 25
        pCfg.timeoutIntervalForResource = 25
        self.pexelsSession = URLSession(configuration: pCfg)

        let oCfg = URLSessionConfiguration.ephemeral
        oCfg.timeoutIntervalForRequest = 120
        oCfg.timeoutIntervalForResource = 120
        self.openAISession = URLSession(configuration: oCfg)
    } // End init

    func generateIconicImage(locationName: String) async throws -> URL {
        let apiKey = infoPlistKey("PEXELS_API_KEY")
        guard !apiKey.isEmpty else {
            throw NSError(domain: "Pexels", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing PEXELS_API_KEY"])
        } // End guard PEXELS_API_KEY

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
        req.timeoutInterval = 25
        req.setValue(apiKey, forHTTPHeaderField: "Authorization")

        #if DEBUG
        DebugLog.api("Pexels GET \(url.absoluteString)")
        #endif

        let (data, resp) = try await pexelsSession.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1

        #if DEBUG
        DebugLog.api("Pexels status \(code)")
        #endif

        guard (200...299).contains(code) else {
            throw NSError(
                domain: "Pexels",
                code: code,
                userInfo: [NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? "HTTP \(code)"]
            )
        } // End guard status

        let decoded = try JSONDecoder().decode(PexelsSearchResponse.self, from: data)
        guard let photo = decoded.photos.first else {
            throw NSError(domain: "Pexels", code: 404, userInfo: [NSLocalizedDescriptionKey: "No photo found for \(query)"])
        } // End guard photo

        guard let imageURL = photo.src.bestURL() else {
            throw NSError(domain: "Pexels", code: 422, userInfo: [NSLocalizedDescriptionKey: "No usable image URL returned"])
        } // End guard imageURL

        AttributionStore.addPexelsIconic(
            photographer: photo.photographer,
            pageURL: URL(string: photo.url),
            imageURL: imageURL
        )

        return imageURL
    } // End func generateIconicImage (long)

    func generateIconicLandmarkImage(locationName: String, timeoutSeconds: TimeInterval) async throws -> URL {
        let apiKey = infoPlistKey("OPENAI_API_KEY")
        guard !apiKey.isEmpty else {
            throw NSError(domain: "OpenAI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing OPENAI_API_KEY"])
        } // End guard OPENAI_API_KEY

        let query = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            throw NSError(domain: "OpenAI", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing location name"])
        } // End guard query

        let opTimeout = max(120, timeoutSeconds)

        let prompt = try await generatePromptViaChat(locationName: query, apiKey: apiKey, timeoutSeconds: opTimeout)
        let imageData = try await generateImageData(prompt: prompt, apiKey: apiKey, timeoutSeconds: opTimeout)

        let fileURL = try FileStore.savePNG(data: imageData, prefix: "ai_")
        AttributionStore.addOpenAIIconic(imageURL: fileURL, prompt: prompt)

        #if DEBUG
        DebugLog.api("OpenAI prompt: \(prompt)")
        DebugLog.api("OpenAI image saved: \(fileURL.absoluteString)")
        #endif

        return fileURL
    } // End func generateIconicLandmarkImage (long)

    private func generatePromptViaChat(locationName: String, apiKey: String, timeoutSeconds: TimeInterval) async throws -> String {
        let endpoint = URL(string: "https://api.openai.com/v1/responses")!
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.timeoutInterval = max(120, timeoutSeconds)
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let input = """
        Write a single concise prompt for an iconic landmark travel photograph of: \(locationName).
        Constraints: photographic, realistic, no text, no watermark, no logos, vivid lighting, high detail.
        Return only the prompt text.
        """

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "input": input
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await openAISession.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
        guard (200...299).contains(code) else {
            throw NSError(domain: "OpenAI", code: code, userInfo: [NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? "HTTP \(code)"])
        } // End guard status

        let decoded = try JSONDecoder().decode(OpenAIResponsesResponse.self, from: data)
        guard let text = decoded.outputText?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            throw NSError(domain: "OpenAI", code: 2, userInfo: [NSLocalizedDescriptionKey: "No prompt returned"])
        } // End guard prompt text

        return text
    } // End func generatePromptViaChat (long)

    private func generateImageData(prompt: String, apiKey: String, timeoutSeconds: TimeInterval) async throws -> Data {
        let endpoint = URL(string: "https://api.openai.com/v1/images/generations")!
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.timeoutInterval = max(120, timeoutSeconds)
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-image-1",
            "prompt": prompt
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await openAISession.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
        guard (200...299).contains(code) else {
            throw NSError(domain: "OpenAI", code: code, userInfo: [NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? "HTTP \(code)"])
        } // End guard status

        let decoded = try JSONDecoder().decode(OpenAIImagesResponse.self, from: data)
        guard let b64 = decoded.data.first?.b64_json, let imageData = Data(base64Encoded: b64) else {
            throw NSError(domain: "OpenAI", code: 3, userInfo: [NSLocalizedDescriptionKey: "No image returned"])
        } // End guard base64 decode

        return imageData
    } // End func generateImageData (long)

    private func infoPlistKey(_ name: String) -> String {
        let raw = (Bundle.main.object(forInfoDictionaryKey: name) as? String) ?? ""
        return raw.trimmingCharacters(in: .whitespacesAndNewlines)
    } // End func infoPlistKey
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
        let type: String? // End type
        let content: [Content]? // End content
    } // End Output

    struct Content: Decodable {
        let type: String? // End type
        let text: String? // End text
    } // End Content
} // End OpenAIResponsesResponse

private struct OpenAIImagesResponse: Decodable {
    var data: [Item] // End data

    struct Item: Decodable {
        var b64_json: String? // End b64_json
    } // End Item
} // End OpenAIImagesResponse
