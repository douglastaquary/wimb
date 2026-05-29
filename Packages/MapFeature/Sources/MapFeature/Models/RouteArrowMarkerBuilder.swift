//
//  RouteArrowMarkerBuilder.swift
//  MapFeature
//

import CoreLocation
import Foundation
import WIMBCore

/// Gera marcadores de direção ao longo da polilinha (live tracking).
enum RouteArrowMarkerBuilder {
    static func markers(
        along coordinates: [CLLocationCoordinate2D],
        spacingMeters: Double = 280
    ) -> [TransportMapAnnotation] {
        guard coordinates.count >= 2, spacingMeters > 0 else { return [] }

        var result: [TransportMapAnnotation] = []
        var carryOver: Double = 0
        var markerIndex = 0

        for segmentIndex in 0..<(coordinates.count - 1) {
            let start = coordinates[segmentIndex]
            let end = coordinates[segmentIndex + 1]
            let startCoord = Coordinate(start)
            let endCoord = Coordinate(end)
            let segmentLength = startCoord.distance(to: endCoord)
            guard segmentLength > 0 else { continue }

            let bearing = startCoord.bearing(to: endCoord)
            var position = carryOver

            while position < segmentLength {
                let ratio = position / segmentLength
                let latitude = start.latitude + (end.latitude - start.latitude) * ratio
                let longitude = start.longitude + (end.longitude - start.longitude) * ratio

                result.append(
                    TransportMapAnnotation(
                        id: "route-arrow-\(markerIndex)",
                        kind: .routeArrow,
                        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                        vehicleHeading: bearing
                    )
                )
                markerIndex += 1
                position += spacingMeters
            }

            carryOver = position - segmentLength
        }

        return result
    }
}
