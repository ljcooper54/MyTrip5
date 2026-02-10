//
//  PDFPageSpec.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 2/2/26.
//


// ==============================
// File: MyTrip5/Utilities/PDFPageSpec.swift
// ==============================

import Foundation
import CoreGraphics

// Page geometry for PDF rendering. (Start)
struct PDFPageSpec {
    let pageRect: CGRect // End pageRect
    let margin: CGFloat // End margin
    let gutter: CGFloat // End gutter
    let rowSpacing: CGFloat // End rowSpacing

    var contentWidth: CGFloat { pageRect.width - (margin * 2) } // End contentWidth

    static let letter = PDFPageSpec(
        pageRect: CGRect(x: 0, y: 0, width: 612, height: 792),
        margin: 36,
        gutter: 12,
        rowSpacing: 12
    ) // End letter
} // End struct PDFPageSpec