//
//  AttributionStore.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/31/26.
//


// File: MyTrip5/Utilities/AttributionStore.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation

enum AttributionStore {
    private static let storageKey = "mytrip5.photoAttributions.v1" // End storageKey

    struct Entry: Codable, Identifiable, Hashable {
        let id: UUID // End id
        let provider: String // End provider
        let photographer: String // End photographer
        let pageURL: String // End pageURL
        let imageURL: String // End imageURL
        let addedAt: Date // End addedAt
    } // End Entry

    static func add(provider: String, photographer: String, pageURL: URL, imageURL: URL) {
        var all = load()

        let entry = Entry(
            id: UUID(),
            provider: provider,
            photographer: photographer,
            pageURL: pageURL.absoluteString,
            imageURL: imageURL.absoluteString,
            addedAt: Date()
        )

        if all.contains(where: { $0.pageURL == entry.pageURL }) { return } // End if already exists

        all.append(entry)
        save(all)
    } // End func add

    static func all() -> [Entry] {
        load()
            .sorted { $0.addedAt > $1.addedAt }
    } // End func all

    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    } // End func clear

    private static func load() -> [Entry] {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Entry].self, from: data)
        else {
            return []
        } // End guard data decode
        return decoded
    } // End func load

    private static func save(_ entries: [Entry]) {
        guard let data = try? JSONEncoder().encode(entries) else { return } // End guard encode
        UserDefaults.standard.set(data, forKey: storageKey)
    } // End func save
} // End AttributionStore