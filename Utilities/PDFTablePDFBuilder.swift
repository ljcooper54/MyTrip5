// ==============================
// File: MyTrip5/Utilities/PDFTablePDFBuilder.swift
// ==============================

import Foundation
import UIKit
import SwiftUI

// Builds table-PDF rows by rendering SwiftUI rows to images. (Start)
enum PDFTablePDFBuilder {
    static func buildRows(cards: [TripCard], temperatureUnit: TemperatureUnit, contentWidth: CGFloat) async -> [RenderedRow] {
        var out: [RenderedRow] = []

        for card in cards {
            let view = TablePrintRowView(card: card, unit: temperatureUnit)
                .frame(width: contentWidth)
                .padding(.vertical, 4)
                .padding(.horizontal, 6)

            if let img = await renderSwiftUIView(view) {
                out.append(.init(image: img, size: img.size))
            } // End if let img
        } // End for card in cards

        return out
    } // End func buildRows (long)

    @MainActor
    private static func renderSwiftUIView<V: View>(_ view: V) async -> UIImage? {
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: view)
            return renderer.uiImage
        } // End if #available
        return nil
    } // End func renderSwiftUIView
} // End enum PDFTablePDFBuilder

struct RenderedRow {
    let image: UIImage // End image
    let size: CGSize // End size
} // End struct RenderedRow
