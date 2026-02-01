//
//  PictureRef.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/28/26.
//


// File: MyTrip5/Model/PictureRef.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation

// This represents either a Photos asset identifier or a URL image. (Start)
enum PictureRef: Codable, Equatable, Identifiable {
    case photoAsset(id: String)
    case url(String)

    var id: String {
        switch self {
        case .photoAsset(let id): return "photo:\(id)"
        case .url(let url): return "url:\(url)"
        }
    }

    static func decodeArray(_ data: Data?) -> [PictureRef]? {
        guard let data else { return nil }
        return try? JSONDecoder().decode([PictureRef].self, from: data)
    }

    static func encodeArray(_ refs: [PictureRef]) -> Data? {
        try? JSONEncoder().encode(refs)
    }
}
// End PictureRef