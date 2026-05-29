//
//  ReverseGeocoder.swift
//  TransportEngine
//

import CoreLocation
import Foundation
import WIMBCore

/// Geocodificação reversa para busca de paradas próximas.
public enum ReverseGeocoder {
    public static func streetQuery(for coordinate: Coordinate) async -> String {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                if let street = placemark.thoroughfare, !street.isEmpty {
                    return street
                }
                if let name = placemark.name, !name.isEmpty {
                    return name
                }
                if let locality = placemark.subLocality, !locality.isEmpty {
                    return locality
                }
            }
        } catch {
            // Fallback abaixo.
        }

        return "São Paulo"
    }
}
