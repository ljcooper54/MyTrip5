//
//  PDFCardsPDFBuilder.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 2/2/26.
//


// ==============================
// File: MyTrip5/Utilities/PDFCardsPDFBuilder.swift
// ==============================

import Foundation
import UIKit

// Builds the Cards-style PDF (header + 2-up photos). (Start)
enum PDFCardsPDFBuilder {
    static func buildCardsPDF(cards: [TripCard], temperatureUnit: TemperatureUnit, spec: PDFPageSpec) async throws -> Data {
        let sections = try await buildSections(cards: cards, temperatureUnit: temperatureUnit)

        return PDFRenderCore.renderPDF(page: spec) { ctx, page in
            for section in sections {
                var y = page.margin
                ctx.beginPage()

                y = PDFRenderCore.drawCardHeader(section.headerText, spec: page, y: y)
                y += 8

                let colW = (page.contentWidth - page.gutter) / 2.0
                let cellH = colW * 0.75

                var col = 0
                var x = page.margin
                var rowH: CGFloat = 0

                for img in section.images {
                    if y + cellH > page.pageRect.height - page.margin {
                        ctx.beginPage()
                        y = page.margin
                        y = PDFRenderCore.drawCardHeader(section.headerText, spec: page, y: y)
                        y += 8
                        col = 0
                        x = page.margin
                        rowH = 0
                    } // End if new page

                    let target = CGRect(x: x, y: y, width: colW, height: cellH)
                    PDFRenderCore.drawImage(img, rect: target)
                    rowH = max(rowH, target.height)

                    if col == 0 {
                        col = 1
                        x = page.margin + colW + page.gutter
                    } else {
                        col = 0
                        x = page.margin
                        y += rowH + page.rowSpacing
                        rowH = 0
                    } // End if/else col switch
                } // End for img in section.images

                if col == 1 {
                    y += rowH + page.rowSpacing
                } // End if dangling last image
            } // End for section in sections
        } // End renderPDF closure (long)
    } // End func buildCardsPDF (long)

    private static func buildSections(cards: [TripCard], temperatureUnit: TemperatureUnit) async throws -> [CardSection] {
        var out: [CardSection] = []

        for card in cards {
            let header = PDFCardHeaderTextBuilder.build(card: card, unit: temperatureUnit)
            var images: [UIImage] = []

            for ref in card.pictures {
                if let img = try await PicturePDFImageLoader.loadUIImage(from: ref) {
                    images.append(img)
                } // End if img (skip missing)
            } // End for ref in card.pictures

            out.append(.init(headerText: header, images: images))
        } // End for card in cards

        return out
    } // End func buildSections (long)
} // End enum PDFCardsPDFBuilder

struct CardSection {
    let headerText: NSAttributedString // End headerText
    let images: [UIImage] // End images
} // End struct CardSection