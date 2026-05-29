//
//  TransportMapAnnotation.swift
//  MapFeature
//

import CoreLocation
import Foundation
import MapKit
import WIMBCore

/// Anotação unificada para veículos e paradas (Map iOS 16).
public struct TransportMapAnnotation: Identifiable {
    public enum Kind {
        case vehicle
        case stop
        case routeArrow
    }

    public let id: String
    public let kind: Kind
    public let coordinate: CLLocationCoordinate2D
    public let vehiclePrefix: String?
    public let vehicleHeading: Double
    public let stopName: String?

    public init(vehicle: VehicleMapItem) {
        self.init(
            id: "vehicle-\(vehicle.id.uuidString)",
            kind: .vehicle,
            coordinate: vehicle.coordinate,
            vehiclePrefix: vehicle.prefix,
            vehicleHeading: vehicle.heading
        )
    }

    public init(
        id: String,
        kind: Kind,
        coordinate: CLLocationCoordinate2D,
        vehiclePrefix: String? = nil,
        vehicleHeading: Double = 0,
        stopName: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.coordinate = coordinate
        self.vehiclePrefix = vehiclePrefix
        self.vehicleHeading = vehicleHeading
        self.stopName = stopName
    }

    public init(stop: StopMapItem) {
        self.init(
            id: "stop-\(stop.id)",
            kind: .stop,
            coordinate: stop.coordinate,
            stopName: stop.name
        )
    }
}

public enum MapRegionFitter {
    public static func region(containing coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion? {
        guard !coordinates.isEmpty else { return nil }

        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)

        guard
            let minLat = latitudes.min(),
            let maxLat = latitudes.max(),
            let minLon = longitudes.min(),
            let maxLon = longitudes.max()
        else {
            return nil
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: max(0.012, (maxLat - minLat) * 1.5),
            longitudeDelta: max(0.012, (maxLon - minLon) * 1.5)
        )

        return MKCoordinateRegion(center: center, span: span)
    }
}
