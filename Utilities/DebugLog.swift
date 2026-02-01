//
//  DebugLog.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/28/26.
//


// File: MyTrip5/Utilities/DebugLog.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation

// This logs API requests/responses under DEBUG. (Start)
enum DebugLog {
    static func api(_ message: String) {
        #if DEBUG
        print("🛰️ API:", message)
        #endif
    }

    static func error(_ message: String) {
        #if DEBUG
        print("🧨 ERROR:", message)
        #endif
    }
}
// End DebugLog