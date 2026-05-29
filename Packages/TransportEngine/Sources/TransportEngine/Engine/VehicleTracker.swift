//
//  VehicleTracker.swift
//  TransportEngine
//

import Foundation
import WIMBCore

/// Mescla posições novas com histórico para animação no mapa.
enum VehicleTracker {
    static func merge(
        existing: [Vehicle],
        with incoming: [Vehicle]
    ) -> [Vehicle] {
        var existingByPrefix: [String: Vehicle] = [:]
        for vehicle in existing {
            existingByPrefix[vehicle.prefix] = vehicle
        }

        return incoming.map { incomingVehicle in
            guard let current = existingByPrefix[incomingVehicle.prefix] else {
                return incomingVehicle
            }

            if current.coordinate == incomingVehicle.coordinate {
                return current
            }

            return Vehicle(
                id: current.id,
                prefix: incomingVehicle.prefix,
                accessible: incomingVehicle.accessible,
                lastUpdateTime: incomingVehicle.lastUpdateTime,
                coordinate: incomingVehicle.coordinate,
                previousCoordinate: current.coordinate,
                arrivalForecast: incomingVehicle.arrivalForecast
            )
        }
    }
}
