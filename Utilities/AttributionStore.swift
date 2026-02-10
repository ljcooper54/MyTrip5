// File: MyTrip5/Utilities/AttributionStore.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation

enum AttributionStore {
    private static let storageKey = "mytrip5.photoAttributions.v2" // End storageKey

    enum Provider: String, Codable {
        case pexels // End pexels
        case openai // End openai
    } // End Provider

    enum Usage: String, Codable {
        case iconicPexels // End iconicPexels
        case iconicOpenAI // End iconicOpenAI
    } // End Usage

    struct Entry: Codable, Identifiable, Hashable {
        let id: UUID // End id
        let provider: Provider // End provider
        let usage: Usage // End usage
        let photographer: String? // End photographer
        let pageURL: String? // End pageURL
        let imageURL: String // End imageURL
        let prompt: String? // End prompt
        let addedAt: Date // End addedAt
    } // End Entry

    static func addPexelsIconic(photographer: String, pageURL: URL?, imageURL: URL) {
        add(
            provider: .pexels,
            usage: .iconicPexels,
            photographer: photographer,
            pageURL: pageURL,
            imageURL: imageURL,
            prompt: nil
        )
    } // End func addPexelsIconic

    static func addOpenAIIconic(imageURL: URL, prompt: String?) {
        add(
            provider: .openai,
            usage: .iconicOpenAI,
            photographer: nil,
            pageURL: nil,
            imageURL: imageURL,
            prompt: prompt
        )
    } // End func addOpenAIIconic

    static func has(provider: Provider, usage: Usage, imageURLString: String) -> Bool {
        let target = normalizeURLString(imageURLString)
        return load().contains(where: { $0.provider == provider && $0.usage == usage && normalizeURLString($0.imageURL) == target })
    } // End func has

    static func all() -> [Entry] {
        load().sorted { $0.addedAt > $1.addedAt }
    } // End func all

    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    } // End func clear

    private static func add(
        provider: Provider,
        usage: Usage,
        photographer: String?,
        pageURL: URL?,
        imageURL: URL,
        prompt: String?
    ) {
        var all = load()

        let entry = Entry(
            id: UUID(),
            provider: provider,
            usage: usage,
            photographer: photographer,
            pageURL: pageURL?.absoluteString,
            imageURL: imageURL.absoluteString,
            prompt: prompt,
            addedAt: Date()
        )

        if all.contains(where: { normalizeURLString($0.imageURL) == normalizeURLString(entry.imageURL) && $0.provider == provider && $0.usage == usage }) {
            return
        } // End if already exists

        all.append(entry)
        save(all)
    } // End func add (long)

    private static func load() -> [Entry] {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Entry].self, from: data)
        else {
            return []
        } // End guard decode

        return decoded
    } // End func load

    private static func save(_ entries: [Entry]) {
        guard let data = try? JSONEncoder().encode(entries) else { return } // End guard encode
        UserDefaults.standard.set(data, forKey: storageKey)
    } // End func save

    private static func normalizeURLString(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines)
    } // End func normalizeURLString
} // End AttributionStore
