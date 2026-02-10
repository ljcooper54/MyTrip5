//
//  PhotoURLMigration.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 2/2/26.
//


// ==============================
// File: MyTrip5/Utilities/PhotoURLMigration.swift  (NEW)
// ==============================

import Foundation
import SwiftData

// This one-time migration removes missing local file:// picture refs from cards. (Start)
enum PhotoURLMigration {
    private static let migrationKey = "didMigrateMissingLocalPhotoURLs_v1" // End migrationKey

    @MainActor
    static func runIfNeeded(cards: [TripCard], modelContext: ModelContext) {
        if UserDefaults.standard.bool(forKey: migrationKey) { return } // End if already migrated

        var removedCount = 0
        var touchedCards = 0

        for card in cards {
            let original = card.pictures
            let filtered = filterMissingLocalFiles(from: original, removedCount: &removedCount)

            if filtered.count != original.count {
                card.pictures = filtered
                card.primaryPictureIndex = clampPrimaryIndex(card.primaryPictureIndex, count: filtered.count)
                card.touchUpdated()
                touchedCards += 1
            } // End if filtered != original
        } // End for card in cards

        if touchedCards > 0 {
            try? modelContext.save()
        } // End if touchedCards > 0

        UserDefaults.standard.set(true, forKey: migrationKey)

        #if DEBUG
        DebugLog.api("PhotoURLMigration: touchedCards=\(touchedCards), removedRefs=\(removedCount)")
        #endif
    } // End func runIfNeeded (long)

    private static func filterMissingLocalFiles(from pictures: [PictureRef], removedCount: inout Int) -> [PictureRef] {
        var out: [PictureRef] = []

        for ref in pictures {
            if case .url(let s) = ref {
                if let url = URL(string: s), url.isFileURL {
                    if FileManager.default.fileExists(atPath: url.path) {
                        out.append(ref)
                    } else {
                        removedCount += 1
                    } // End if/else file exists
                    continue
                } // End if fileURL
            } // End if case .url

            out.append(ref)
        } // End for ref in pictures

        return out
    } // End func filterMissingLocalFiles (long)

    private static func clampPrimaryIndex(_ value: Int, count: Int) -> Int {
        if count <= 0 { return 0 } // End if empty
        return min(max(0, value), count - 1)
    } // End func clampPrimaryIndex
} // End PhotoURLMigration