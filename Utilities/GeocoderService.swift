// File: MyTrip5/Utilities/GeocoderService.swift
// Copyright H2so4 Consulting LLC, 2026

import Foundation
import MapKit
import CoreLocation

// This wraps forward + reverse geocoding using MapKit iOS 26 APIs (no placemark). (Start)
final class GeocoderService {

    func forwardGeocode(name: String) async throws -> CLLocationCoordinate2D {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw NSError(domain: "GeocoderService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Empty address string"])
        } // End guard !trimmed.isEmpty

        guard let request = MKGeocodingRequest(addressString: trimmed) else {
            throw NSError(domain: "GeocoderService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create MKGeocodingRequest"])
        } // End guard request

        let items = try await requestMapItems(request: request)
        guard let coord = items.first?.location.coordinate else {
            throw NSError(domain: "GeocoderService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No coordinate found"])
        } // End guard coord

        return coord
    } // End forwardGeocode(name:)

    func reverseGeocode(coord: CLLocationCoordinate2D) async throws -> String {
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)

        guard let request = MKReverseGeocodingRequest(location: location) else {
            throw NSError(domain: "GeocoderService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Could not create MKReverseGeocodingRequest"])
        } // End guard request

        let items = try await requestMapItems(request: request)
        guard let best = items.first else {
            return "\(coord.latitude), \(coord.longitude)"
        } // End guard best

        if let cityWithContext = best.addressRepresentations?.cityWithContext, !cityWithContext.isEmpty {
            if let name = best.name, !name.isEmpty {
                return "\(name), \(cityWithContext)"
            } // End if let name
            return cityWithContext
        } // End if let cityWithContext

        if let short = best.address?.shortAddress, !short.isEmpty {
            return short
        } // End if let short

        if let full = best.address?.fullAddress, !full.isEmpty {
            return full
        } // End if let full

        if let name = best.name, !name.isEmpty {
            return name
        } // End if let name

        return "\(coord.latitude), \(coord.longitude)"
    } // End reverseGeocode(coord:)

    private func requestMapItems(request: MKGeocodingRequest) async throws -> [MKMapItem] {
        try await withCheckedThrowingContinuation { cont in
            request.getMapItems { items, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                } // End if let error
                cont.resume(returning: items ?? [])
            } // End getMapItems completionHandler
        } // End withCheckedThrowingContinuation
    } // End requestMapItems(request: MKGeocodingRequest)

    private func requestMapItems(request: MKReverseGeocodingRequest) async throws -> [MKMapItem] {
        try await withCheckedThrowingContinuation { cont in
            request.getMapItems { items, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                } // End if let error
                cont.resume(returning: items ?? [])
            } // End getMapItems completionHandler
        } // End withCheckedThrowingContinuation
    } // End requestMapItems(request: MKReverseGeocodingRequest)

} // End GeocoderService
// End GeocoderService.swift
