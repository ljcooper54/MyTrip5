// File: MyTrip5/Utilities/PDFPrintService.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation
import UIKit
import CoreGraphics

// Public entry points for PDF printing. (Start)
enum PDFPrintService {
    static func makeTablePDF(cards: [TripCard], temperatureUnit: TemperatureUnit) async throws -> URL {
        let spec = PDFPageSpec.letter
        let rows = await PDFTablePDFBuilder.buildRows(
            cards: cards,
            temperatureUnit: temperatureUnit,
            contentWidth: spec.contentWidth
        ) // End buildRows

        let data = PDFRenderCore.renderPDF(page: spec) { ctx, page in
            ctx.beginPage() // Start first page (required) // End beginPage
            var y = page.margin
            y = PDFRenderCore.drawTitle("MyTrip — Table", ctx: ctx, spec: page, y: y)

            for row in rows {
                if y + row.size.height > page.pageRect.height - page.margin {
                    ctx.beginPage() // Start next page (required) // End beginPage
                    y = page.margin
                    y = PDFRenderCore.drawTitle("MyTrip — Table", ctx: ctx, spec: page, y: y)
                } // End if new page

                row.image.draw(in: CGRect(x: page.margin, y: y, width: row.size.width, height: row.size.height))
                y += row.size.height + 6
            } // End for row in rows
        } // End renderPDF

        return try PDFRenderCore.savePDFData(data, prefix: "table_")
    } // End func makeTablePDF (long)

    static func makeCardsPDF(cards: [TripCard], temperatureUnit: TemperatureUnit) async throws -> URL {
        let spec = PDFPageSpec.letter
        let data = try await PDFCardsPDFBuilder.buildCardsPDF(
            cards: cards,
            temperatureUnit: temperatureUnit,
            spec: spec
        ) // End buildCardsPDF

        return try PDFRenderCore.savePDFData(data, prefix: "cards_")
    } // End func makeCardsPDF
} // End enum PDFPrintService
