//
//  LiveMapFocus.swift
//  MapFeature
//

import CoreLocation
import MapKit
import WIMBCore

/// Enquadramento e câmera do live tracking — zoom no ônibus, estilo Uber.
enum LiveMapFocus {
    /// Mostra ponto azul só se o usuário estiver perto da rota.
    static let userProximityMeters: CLLocationDistance = 2_000

    /// ~350 m de raio — ruas legíveis, ícone grande o suficiente para acompanhar.
    static let streetLevelSpan = MKCoordinateSpan(latitudeDelta: 0.0032, longitudeDelta: 0.0032)

    struct Target {
        let primaryVehicleID: UUID
        let center: CLLocationCoordinate2D
        let span: MKCoordinateSpan
        let showsUserLocation: Bool
    }

    /// Ônibus principal: mais próximo do usuário (se perto) ou primeiro da lista da API.
    static func primaryVehicle(
        in vehicles: [Vehicle],
        userLocation: CLLocationCoordinate2D?
    ) -> Vehicle? {
        guard !vehicles.isEmpty else { return nil }

        if let userLocation {
            let nearest = vehicles.min {
                $0.coordinate.distance(to: Coordinate(userLocation))
                    < $1.coordinate.distance(to: Coordinate(userLocation))
            }
            if let nearest,
               nearest.coordinate.distance(to: Coordinate(userLocation)) <= userProximityMeters {
                return nearest
            }
        }

        return vehicles[0]
    }

    static func target(
        vehicles: [Vehicle],
        userLocation: CLLocationCoordinate2D?,
        followCoordinate: CLLocationCoordinate2D? = nil
    ) -> Target? {
        guard let primary = primaryVehicle(in: vehicles, userLocation: userLocation) else {
            return nil
        }

        let center = followCoordinate ?? primary.coordinate.clCoordinate

        let showsUser: Bool
        if let userLocation {
            showsUser = Coordinate(userLocation).distance(to: primary.coordinate) <= userProximityMeters
        } else {
            showsUser = false
        }

        return Target(
            primaryVehicleID: primary.id,
            center: center,
            span: streetLevelSpan,
            showsUserLocation: showsUser
        )
    }

    static func region(for target: Target) -> MKCoordinateRegion {
        MKCoordinateRegion(center: target.center, span: target.span)
    }
}
