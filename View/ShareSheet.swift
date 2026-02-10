//
//  ShareSheet.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 2/2/26.
//


// ==============================
// File: MyTrip5/View/ShareSheet.swift  (NEW)
// ==============================

import SwiftUI
import UIKit

// This wraps UIActivityViewController for sharing a generated PDF URL. (Start)
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any] // End activityItems

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    } // End func makeUIViewController

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates required. (End updateUIViewController)
    } // End func updateUIViewController
} // End ShareSheet