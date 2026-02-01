// File: MyTrip5/View/PictureDisplayView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI
import UIKit

struct PictureDisplayView: View {
    let ref: PictureRef // End ref

    var body: some View {
        GeometryReader { geo in
            Group {
                switch ref {
                case .photoAsset(let id):
                    AssetImageView(assetIdentifier: id)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()

                case .url(let urlString):
                    if let url = URL(string: urlString) {
                        if url.isFileURL {
                            fileImage(url: url, size: geo.size)
                        } else {
                            remoteImage(url: url, size: geo.size)
                        } // End if/else url.isFileURL
                    } else {
                        missingView(size: geo.size, message: "Bad URL")
                    } // End if/else URL(string:)
                } // End switch ref
            } // End Group
        } // End GeometryReader (long)
    } // End body

    private func remoteImage(url: URL, size: CGSize) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: size.width, height: size.height)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
            case .failure:
                missingView(size: size, message: "Download failed")
            @unknown default:
                missingView(size: size, message: "Unknown state")
            } // End switch AsyncImagePhase
        } // End AsyncImage (long)
    } // End func remoteImage

    private func fileImage(url: URL, size: CGSize) -> some View {
        let path = url.path
        if FileManager.default.fileExists(atPath: path),
           let data = try? Data(contentsOf: url),
           let ui = UIImage(data: data) {
            return AnyView(
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
            ) // End AnyView success
        } // End if file exists and decodes

        return AnyView(missingView(size: size, message: "Missing local image")) // End AnyView missing
    } // End func fileImage

    private func missingView(size: CGSize, message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
        } // End VStack missingView
        .frame(width: size.width, height: size.height)
    } // End func missingView
} // End PictureDisplayView
