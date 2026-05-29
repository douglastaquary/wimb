//
//  TripPlace.swift
//  WIMBCore
//

import Foundation

/// Local ou endereço usado no planejador de viagens.
public struct TripPlace: Sendable, Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let subtitle: String?
    public let coordinate: Coordinate

    public init(
        id: String,
        name: String,
        subtitle: String? = nil,
        coordinate: Coordinate
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.coordinate = coordinate
    }

    public var displayTitle: String {
        name
    }
}
