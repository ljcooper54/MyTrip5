// File: MyTrip5/View/CardView.swift
// Copyright H2so4 Consulting LLC, 2026

import SwiftUI
import SwiftData

struct CardView: View {
    @Environment(\.modelContext) private var modelContext // End modelContext
    @EnvironmentObject private var services: AppServices // End services

    @Bindable var card: TripCard // End card

    let canGoPrevCard: Bool // End canGoPrevCard
    let canGoNextCard: Bool // End canGoNextCard
    let goPrevCard: () -> Void // End goPrevCard
    let goNextCard: () -> Void // End goNextCard

    @StateObject private var vm = CardViewModel() // End vm

    var body: some View {
        VStack(spacing: 12) {
            CardHeaderSectionView(
                card: card,
                showingDatePicker: $vm.showingDatePicker,
                showingMap: $vm.showingMap
            ) {
                vm.persist()
            } // End CardHeaderSectionView

            CardWeatherSectionView(card: card, services: services) {
                Task { await vm.refreshWeather(message: "Refreshing weather…") } // End Task refreshWeather
            } // End CardWeatherSectionView

            CardPicturesSectionView(
                card: card,
                canGoPrevCard: canGoPrevCard,
                canGoNextCard: canGoNextCard,
                goPrevCard: goPrevCard,
                goNextCard: goNextCard,
                imageIndex: $vm.imageIndex,
                isGeneratingAI: $vm.isGeneratingIconicImage,
                onDeleteCurrent: { vm.deleteCurrentPicture() },
                onPhotosPicked: { photos in await vm.addPickedPhotos(photos) },
                onGenerateAI: { await vm.fetchIconicImage() }
            ) // End CardPicturesSectionView

            CardActionsRowView(
                onPickFromMap: { vm.showingMap = true },
                onRefreshWeather: { Task { await vm.refreshWeather(message: "Refreshing weather…") } }
            ) // End CardActionsRowView

            Spacer(minLength: 0)

            CardDeleteRowView { vm.confirmDelete = true } // End CardDeleteRowView
        } // End VStack content (long)
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            if vm.isBusy {
                BusyOverlayView(message: vm.busyMessage)
            } // End if vm.isBusy
        } // End overlay
        .onAppear {
            vm.configure(card: card, services: services, modelContext: modelContext)
        } // End onAppear
        .sheet(isPresented: $vm.showingDatePicker) {
            CalendarPickerSheetView(title: "Date", date: $card.date) { _ in
                vm.persist()
                Task { await vm.refreshWeather(message: "Refreshing weather…") } // End Task refresh after date pick
            } // End CalendarPickerSheetView
        } // End sheet showingDatePicker
        .sheet(isPresented: $vm.showingMap) {
            MapPickerView(
                initialCenter: vm.currentCenter(),
                initialSpan: vm.currentSpan()
            ) { selection in
                Task { await vm.applyMapSelection(selection) } // End Task applyMapSelection
            } // End MapPickerView
        } // End sheet showingMap
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } } // End Binding setter
        )) {
            Button("OK", role: .cancel) { vm.errorMessage = nil } // End Button OK
        } message: {
            Text(vm.errorMessage ?? "")
        } // End alert Error
        .alert("Delete card?", isPresented: $vm.confirmDelete) {
            Button("Delete", role: .destructive) { vm.deleteCard() } // End Button Delete
            Button("Cancel", role: .cancel) { } // End Button Cancel
        } message: {
            Text("This cannot be undone.")
        } // End alert Delete card
    } // End body
} // End CardView
