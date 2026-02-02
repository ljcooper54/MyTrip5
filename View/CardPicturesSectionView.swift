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
    let onCancelGenerateAI: () -> Void // End onCancelGenerateAI

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
                        tappableEmptyState
                    } else {
                        let safeIndex = clampIndex(imageIndex)
                        PictureDisplayView(ref: card.pictures[safeIndex])
                            .frame(height: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay { browseOverlay(safeIndex: safeIndex) }
                            .contentShape(Rectangle())
                    } // End if/else pictures empty
                } // End ZStack picture well
                .frame(maxWidth: .infinity)

                navArrow(enabled: canGoNextCard, system: "arrow.right", action: goNextCard)
            } // End HStack

            if !card.pictures.isEmpty {
                HStack {
                    Button(role: .destructive) { onDeleteCurrent() } label: {
                        Label("Delete This Photo", systemImage: "trash")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.red)
                    } // End Button delete picture
                    .buttonStyle(.bordered)

                    Spacer()

                    Text("\(clampIndex(imageIndex) + 1)/\(card.pictures.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } // End HStack
            } // End if has pictures

            HStack {
                addPhotosPickerButton

                Spacer()

                Button {
                    Task { await onGenerateAI() } // End Task
                } label: {
                    if isGeneratingAI {
                        HStack(spacing: 10) {
                            ProgressView()
                            Button("Cancel") { onCancelGenerateAI() } // End Button Cancel
                                .buttonStyle(.bordered)
                        } // End HStack spinner+cancel
                    } else {
                        Text(iconicButtonTitle)
                    } // End if/else generating
                } // End Button Iconic
                .buttonStyle(.borderedProminent)
                .disabled(isGeneratingAI || card.locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } // End HStack buttons
        } // End VStack (long)
        .onAppear { imageIndex = clampIndex(imageIndex) } // End onAppear
        .onChange(of: card.pictures.count) { _, _ in
            imageIndex = clampIndex(imageIndex)
            card.primaryPictureIndex = imageIndex
            card.touchUpdated()
        } // End onChange pictures count
        .onChange(of: imageIndex) { _, newValue in
            imageIndex = clampIndex(newValue)
            card.primaryPictureIndex = imageIndex
            card.touchUpdated()
        } // End onChange imageIndex
    } // End body

    private var iconicButtonTitle: String {
        hasPexelsIconicOnCard() ? "Generate Iconic Image" : "Iconic Image"
    } // End iconicButtonTitle

    private func hasPexelsIconicOnCard() -> Bool {
        for ref in card.pictures {
            if case .url(let s) = ref {
                if AttributionStore.has(provider: .pexels, usage: .iconicPexels, imageURLString: s) { return true } // End if attribution
            } // End if case .url
        } // End for
        return false
    } // End func hasPexelsIconicOnCard

    private var addPhotosPickerButton: some View {
        Group {
            #if canImport(PhotosUI)
            if #available(iOS 16.0, macOS 13.0, *) {
                PhotosPicker(selection: $selectedItems, maxSelectionCount: 0, matching: .images) {
                    Text("Add Photos")
                } // End PhotosPicker label
                .buttonStyle(.bordered)
                .onChange(of: selectedItems) { _, items in
                    Task { await convertAndSend(items) } // End Task convertAndSend
                } // End onChange selectedItems
            } else {
                Text("Add Photos unavailable").foregroundStyle(.secondary)
            } // End if/else availability
            #else
            Text("Add Photos unavailable").foregroundStyle(.secondary)
            #endif
        } // End Group
    } // End addPhotosPickerButton

    private var tappableEmptyState: some View {
        Group {
            #if canImport(PhotosUI)
            if #available(iOS 16.0, macOS 13.0, *) {
                PhotosPicker(selection: $selectedItems, maxSelectionCount: 0, matching: .images) {
                    emptyState
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                } // End PhotosPicker emptyState
                .buttonStyle(.plain)
                .onChange(of: selectedItems) { _, items in
                    Task { await convertAndSend(items) } // End Task convertAndSend
                } // End onChange selectedItems
            } else {
                emptyState
            } // End if/else availability
            #else
            emptyState
            #endif
        } // End Group
    } // End tappableEmptyState

    #if canImport(PhotosUI)
    @available(iOS 16.0, macOS 13.0, *)
    private func convertAndSend(_ items: [PhotosPickerItem]) async {
        var picked: [CardViewModel.PickedPhoto] = []

        for item in items {
            if let id = item.itemIdentifier {
                picked.append(.init(assetIdentifier: id, data: nil))
                continue
            } // End if id

            let data = try? await item.loadTransferable(type: Data.self)
            picked.append(.init(assetIdentifier: nil, data: data))
        } // End for

        await onPhotosPicked(picked)
    } // End func convertAndSend (long)
    #endif

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)
            Text("No Picture").font(.callout).foregroundStyle(.secondary)
            Text("Tap to Add Photos").font(.caption).foregroundStyle(.secondary)
        } // End VStack emptyState
    } // End emptyState

    private func browseOverlay(safeIndex: Int) -> some View {
        HStack {
            if card.pictures.count > 1, safeIndex > 0 {
                Button { imageIndex = max(0, safeIndex - 1) } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.red)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                } // End Button prev
                .padding(.leading, 10)
            } // End if show left

            Spacer()

            if card.pictures.count > 1, safeIndex < card.pictures.count - 1 {
                Button { imageIndex = min(card.pictures.count - 1, safeIndex + 1) } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.red)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                } // End Button next
                .padding(.trailing, 10)
            } // End if show right
        } // End HStack browseOverlay (long)
        .padding(.vertical, 6)
    } // End func browseOverlay

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
        guard !card.pictures.isEmpty else { return 0 } // End guard
        return min(max(0, value), card.pictures.count - 1)
    } // End func clampIndex
} // End CardPicturesSectionView
