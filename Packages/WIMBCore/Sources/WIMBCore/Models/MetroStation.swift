//
//  MetroStation.swift
//  WIMBCore
//

import Foundation

/// Estação de metrô ou monotrilho em São Paulo.
public struct MetroStation: Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String
    /// Nomes das linhas (ex.: "1-Azul", "3-Vermelha").
    public let lines: [String]
    public let coordinate: Coordinate

    public init(id: String, name: String, lines: [String], coordinate: Coordinate) {
        self.id = id
        self.name = name
        self.lines = lines
        self.coordinate = coordinate
    }
}

/// Estação de metrô próxima ao usuário.
public struct NearbyMetroStop: Sendable, Identifiable, Hashable {
    public let station: MetroStation
    public let distanceMeters: Double
    public let walkingMinutes: Int

    public var id: String { station.id }

    public init(station: MetroStation, distanceMeters: Double, walkingMinutes: Int) {
        self.station = station
        self.distanceMeters = distanceMeters
        self.walkingMinutes = walkingMinutes
    }
}
