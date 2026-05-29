//
//  PlaceSearchService.swift
//  TransportEngine
//

import Foundation
import MapKit
import WIMBCore

/// Busca de endereços e pontos de interesse via MapKit.
public enum PlaceSearchService {
    public static func search(
        query: String,
        region: MKCoordinateRegion? = nil
    ) async throws -> [TripPlace] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        request.region = region ?? defaultRegion

        let response = try await MKLocalSearch(request: request).start()

        return response.mapItems.compactMap { item in
            guard let location = item.placemark.location else { return nil }

            let name = item.name ?? item.placemark.name ?? trimmed
            let subtitle = item.placemark.title

            return TripPlace(
                id: placeID(for: location.coordinate),
                name: name,
                subtitle: subtitle,
                coordinate: Coordinate(location.coordinate)
            )
        }
    }

    private static var defaultRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: Coordinate.saoPauloDefault.clCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.35, longitudeDelta: 0.35)
        )
    }

    private static func placeID(for coordinate: CLLocationCoordinate2D) -> String {
        String(format: "%.5f,%.5f", coordinate.latitude, coordinate.longitude)
    }
}
