//
//  AssetImageView.swift
//  MyTrip5
//
//  Created by Lorne Cooper on 1/28/26.
//


// File: MyTrip5/View/AssetImageView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI
import Photos

// This displays a Photos asset by local identifier without persisting image bytes. (Start)
struct AssetImageView: View {
    let assetIdentifier: String
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                ProgressView()
                    .task { await load() }
            }
        }
    }

    private func load() async {
        let results = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
        guard let asset = results.firstObject else { return }

        await withCheckedContinuation { cont in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 1200, height: 1200),
                contentMode: .aspectFill,
                options: {
                    let o = PHImageRequestOptions()
                    o.deliveryMode = .opportunistic
                    o.isNetworkAccessAllowed = true
                    return o
                }()
            ) { img, _ in
                self.image = img
                cont.resume()
            }
        }
    }
}
// End AssetImageView
