// File: MyTrip5/View/CardPicturesSectionView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI

#if canImport(PhotosUI)
import PhotosUI
#endif

struct CardPicturesSectionView: View {
    @Bindable var card: TripCard // End card

    let canGoPrevCard: Bool // End canGoPrevCard
    let canGoNextCard: Bool // End canGoNextCard
    let goPrevCard: () -> Void // End goPrevCard
    let goNextCard: () -> Void // End goNextCard

    @Binding var imageIndex: Int // End imageIndex
    @Binding var isGeneratingAI: Bool // End isGeneratingAI

    let onDeleteCurrent: () -> Void // End onDeleteCurrent
    let onPhotosPicked: ([CardViewModel.PickedPhoto]) async -> Void // End onPhotosPicked
    let onGenerateAI: () async -> Void // End onGenerateAI

    #if canImport(PhotosUI)
    @State private var selectedItems: [PhotosPickerItem] = [] // End selectedItems
    #endif

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                navArrow(enabled: canGoPrevCard, system: "arrow.left", action: goPrevCard)

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 240)

                    if card.pictures.isEmpty {
                        emptyState
                    } else {
                        PictureDisplayView(ref: card.pictures[imageIndex])
                            .frame(height: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay { browseOverlay }
                            .contentShape(Rectangle())
                    } // End if/else pictures empty
                } // End ZStack picture well
                .frame(maxWidth: .infinity)

                navArrow(enabled: canGoNextCard, system: "arrow.right", action: goNextCard)
            } // End HStack card navigation + picture

            if !card.pictures.isEmpty {
                HStack {
                    Button(role: .destructive) { onDeleteCurrent() } label: {
                        Label("Delete This Photo", systemImage: "trash")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.red)
                    } // End Button delete current picture
                    .buttonStyle(.bordered)

                    Spacer()

                    Text("\(imageIndex + 1)/\(card.pictures.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } // End HStack delete/count row
            } // End if has pictures

            HStack {
                photosPickerOrFallback

                Spacer()

                Button {
                    Task { await onGenerateAI() } // End Task onGenerateAI
                } label: {
                    if isGeneratingAI {
                        ProgressView().frame(width: 120)
                    } else {
                        Text("Iconic Image")
                    } // End if/else isGeneratingAI
                } // End Button Iconic Image
                .buttonStyle(.borderedProminent)
                .disabled(isGeneratingAI || card.locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } // End HStack picker + iconic image
        } // End VStack pictures section (long)
        .onAppear { imageIndex = clampIndex(imageIndex) } // End onAppear clamp
        .onChange(of: card.pictures.count) { _, _ in
            imageIndex = clampIndex(imageIndex)
            card.primaryPictureIndex = imageIndex
            card.touchUpdated()
        } // End onChange pictures count
        .onChange(of: imageIndex) { _, newValue in
            card.primaryPictureIndex = newValue
            card.touchUpdated()
        } // End onChange imageIndex
    } // End body

    private var photosPickerOrFallback: some View {
        Group {
            #if canImport(PhotosUI)
            if #available(iOS 16.0, macOS 13.0, *) {
                PhotosPicker(selection: $selectedItems, maxSelectionCount: 0, matching: .images) {
                    Text("Photos")
                } // End PhotosPicker label
                .buttonStyle(.bordered)
                .onChange(of: selectedItems) { _, items in
                    Task { await convertAndSend(items) } // End Task convertAndSend
                } // End onChange selectedItems
            } else {
                Text("Photos unavailable").foregroundStyle(.secondary)
            } // End if/else #available PhotosPicker
            #else
            Text("Photos unavailable").foregroundStyle(.secondary)
            #endif
        } // End Group photosPickerOrFallback
    } // End photosPickerOrFallback

    #if canImport(PhotosUI)
    @available(iOS 16.0, macOS 13.0, *)
    private func convertAndSend(_ items: [PhotosPickerItem]) async {
        var picked: [CardViewModel.PickedPhoto] = []

        for item in items {
            if let id = item.itemIdentifier {
                picked.append(.init(assetIdentifier: id, data: nil))
                continue
            } // End if itemIdentifier

            let data = try? await item.loadTransferable(type: Data.self)
            picked.append(.init(assetIdentifier: nil, data: data))
        } // End for item in items

        await onPhotosPicked(picked)
    } // End func convertAndSend
    #endif

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)
            Text("Tap Photos to add pictures")
                .font(.callout)
                .foregroundStyle(.secondary)
        } // End VStack emptyState
    } // End emptyState

    private var browseOverlay: some View {
        HStack {
            if imageIndex > 0 {
                Button { imageIndex = max(0, imageIndex - 1) } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.red)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                } // End Button image prev
                .padding(.leading, 10)
            } // End if imageIndex > 0

            Spacer()

            if imageIndex < card.pictures.count - 1 {
                Button { imageIndex = min(card.pictures.count - 1, imageIndex + 1) } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.red)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                } // End Button image next
                .padding(.trailing, 10)
            } // End if imageIndex < last
        } // End HStack browseOverlay (long)
        .padding(.vertical, 6)
    } // End browseOverlay

    private func navArrow(enabled: Bool, system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.red)
        } // End Button navArrow
        .buttonStyle(.plain)
        .opacity(enabled ? 1 : 0.15)
        .disabled(!enabled)
    } // End func navArrow

    private func clampIndex(_ value: Int) -> Int {
        guard !card.pictures.isEmpty else { return 0 } // End guard pictures non-empty
        return min(max(0, value), card.pictures.count - 1)
    } // End func clampIndex
} // End CardPicturesSectionView
