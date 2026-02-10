//
//  PDFRenderCore.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 2/2/26.
//


// ==============================
// File: MyTrip5/Utilities/PDFRenderCore.swift
// ==============================

import Foundation
import UIKit

// Shared PDF rendering primitives. (Start)
enum PDFRenderCore {
    static func renderPDF(page: PDFPageSpec, draw: (UIGraphicsPDFRendererContext, PDFPageSpec) -> Void) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: page.pageRect, format: UIGraphicsPDFRendererFormat())
        return renderer.pdfData { ctx in
            draw(ctx, page)
        } // End pdfData
    } // End func renderPDF

    static func drawTitle(_ title: String, ctx: UIGraphicsPDFRendererContext, spec: PDFPageSpec, y: CGFloat) -> CGFloat {
        let font = UIFont.boldSystemFont(ofSize: 18)
        let s = NSAttributedString(string: title, attributes: [.font: font])
        s.draw(in: CGRect(x: spec.margin, y: y, width: spec.contentWidth, height: 26))
        return y + 30
    } // End func drawTitle

    static func drawCardHeader(_ text: NSAttributedString, spec: PDFPageSpec, y: CGFloat) -> CGFloat {
        text.draw(in: CGRect(x: spec.margin, y: y, width: spec.contentWidth, height: 64))
        return y + 52
    } // End func drawCardHeader

    static func drawImage(_ img: UIImage, rect: CGRect) {
        let fitted = aspectFitRect(imageSize: img.size, in: rect)
        img.draw(in: fitted)
    } // End func drawImage

    static func aspectFitRect(imageSize: CGSize, in rect: CGRect) -> CGRect {
        let iw = imageSize.width
        let ih = imageSize.height
        if iw <= 0 || ih <= 0 { return rect } // End if invalid size

        let r = min(rect.width / iw, rect.height / ih)
        let w = iw * r
        let h = ih * r
        return CGRect(x: rect.midX - (w / 2), y: rect.midY - (h / 2), width: w, height: h)
    } // End func aspectFitRect

    static func savePDFData(_ data: Data, prefix: String) throws -> URL {
        let dir = FileManager.default.temporaryDirectory
        let name = "\(prefix)\(Int(Date().timeIntervalSince1970)).pdf"
        let url = dir.appendingPathComponent(name)
        try data.write(to: url, options: [.atomic])
        return url
    } // End func savePDFData
} // End enum PDFRenderCore
