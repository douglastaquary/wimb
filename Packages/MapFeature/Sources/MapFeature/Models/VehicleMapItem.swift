//
//  VehicleMapItem.swift
//  MapFeature
//

import CoreLocation
import Foundation
import MapKit
import WIMBCore

/// Item de mapa derivado de um veículo (compatível com `Map` iOS 16).
public struct VehicleMapItem: Identifiable {
    public let id: UUID
    public let prefix: String
    public let coordinate: CLLocationCoordinate2D
    public let heading: Double

    public init(vehicle: Vehicle) {
        self.id = vehicle.id
        self.prefix = vehicle.prefix
        self.coordinate = vehicle.coordinate.clCoordinate
        self.heading = vehicle.heading
    }
}

public struct StopMapItem: Identifiable {
    public let id: Int
    public let name: String
    public let coordinate: CLLocationCoordinate2D

    public init(stop: Stop) {
        self.id = stop.id
        self.name = stop.name
        self.coordinate = stop.coordinate.clCoordinate
    }
}
