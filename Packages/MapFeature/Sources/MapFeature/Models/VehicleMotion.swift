//
//  VehicleMotion.swift
//  MapFeature
//

import CoreLocation
import Foundation
import WIMBCore

/// Estado de movimento interpolado entre duas posições de polling.
struct VehicleMotion: Identifiable {
    let id: UUID
    let prefix: String
    var origin: CLLocationCoordinate2D
    var destination: CLLocationCoordinate2D
    var heading: Double
    var startedAt: Date
    var duration: TimeInterval

    func coordinate(at date: Date) -> CLLocationCoordinate2D {
        guard duration > 0 else { return destination }

        let elapsed = date.timeIntervalSince(startedAt)
        let progress = min(1, max(0, elapsed / duration))
        let t = progress * progress * (3 - 2 * progress)

        return CLLocationCoordinate2D(
            latitude: origin.latitude + (destination.latitude - origin.latitude) * t,
            longitude: origin.longitude + (destination.longitude - origin.longitude) * t
        )
    }

    /// Direção de deslocamento (frente do ícone) com base no trecho animado.
    func displayHeading(at date: Date = Date()) -> Double {
        let from = duration > 0 ? origin : coordinate(at: date)
        let to = destination
        if VehicleMotionTracker.coordinatesDiffer(from, to) {
            return Coordinate(from).bearing(to: Coordinate(to))
        }
        return heading
    }
}

enum VehicleMotionTracker {
    static let defaultDuration: TimeInterval = 9.5

    static func merge(
        existing: [UUID: VehicleMotion],
        vehicles: [Vehicle],
        animated: Bool,
        now: Date = Date(),
        duration: TimeInterval = defaultDuration
    ) -> [UUID: VehicleMotion] {
        var result = existing
        let vehicleIds = Set(vehicles.map(\.id))

        for vehicle in vehicles {
            let target = vehicle.coordinate.clCoordinate

            if let motion = result[vehicle.id] {
                let displayed = motion.coordinate(at: now)
                let moved = coordinatesDiffer(displayed, target)

                if animated && moved {
                    result[vehicle.id] = VehicleMotion(
                        id: vehicle.id,
                        prefix: vehicle.prefix,
                        origin: displayed,
                        destination: target,
                        heading: Self.travelHeading(from: displayed, to: target, vehicle: vehicle, fallback: motion.heading),
                        startedAt: now,
                        duration: duration
                    )
                } else if !animated || !moved {
                    result[vehicle.id] = VehicleMotion(
                        id: vehicle.id,
                        prefix: vehicle.prefix,
                        origin: target,
                        destination: target,
                        heading: Self.travelHeading(from: target, to: target, vehicle: vehicle, fallback: motion.heading),
                        startedAt: now,
                        duration: 0
                    )
                }
            } else {
                result[vehicle.id] = VehicleMotion(
                    id: vehicle.id,
                    prefix: vehicle.prefix,
                    origin: target,
                    destination: target,
                    heading: Self.travelHeading(from: target, to: target, vehicle: vehicle, fallback: 0),
                    startedAt: now,
                    duration: 0
                )
            }
        }

        return result.filter { vehicleIds.contains($0.key) }
    }

    static func coordinatesDiffer(
        _ lhs: CLLocationCoordinate2D,
        _ rhs: CLLocationCoordinate2D
    ) -> Bool {
        abs(lhs.latitude - rhs.latitude) > 0.000001
            || abs(lhs.longitude - rhs.longitude) > 0.000001
    }

    private static func travelHeading(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        vehicle: Vehicle,
        fallback: Double
    ) -> Double {
        if coordinatesDiffer(origin, destination) {
            return Coordinate(origin).bearing(to: Coordinate(destination))
        }
        if vehicle.hasMoved { return vehicle.heading }
        return fallback != 0 ? fallback : vehicle.heading
    }
}
