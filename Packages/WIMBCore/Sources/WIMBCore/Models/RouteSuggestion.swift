//
//  RouteSuggestion.swift
//  WIMBCore
//

import Foundation

/// Passo individual de uma rota sugerida.
public struct RouteStep: Sendable, Hashable, Identifiable {
    public enum Kind: String, Sendable, Hashable, Codable {
        case walk
        case bus
    }

    public let id: UUID
    public let kind: Kind
    public let title: String
    public let subtitle: String?
    public let durationMinutes: Int

    public init(
        id: UUID = UUID(),
        kind: Kind,
        title: String,
        subtitle: String? = nil,
        durationMinutes: Int
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.durationMinutes = durationMinutes
    }
}

/// Rota sugerida heurística (origem → destino via linha SPTrans).
public struct RouteSuggestion: Sendable, Identifiable, Hashable {
    public let id: UUID
    public let line: TransportLine
    public let boardingStop: Stop
    public let alightingStop: Stop
    public let walkToBoardMinutes: Int
    public let walkFromAlightMinutes: Int
    public let busRideMinutes: Int
    public let waitMinutes: Int
    public let totalMinutes: Int
    public let fareCents: Int
    public let steps: [RouteStep]

    public init(
        id: UUID = UUID(),
        line: TransportLine,
        boardingStop: Stop,
        alightingStop: Stop,
        walkToBoardMinutes: Int,
        walkFromAlightMinutes: Int,
        busRideMinutes: Int,
        waitMinutes: Int,
        totalMinutes: Int,
        fareCents: Int,
        steps: [RouteStep]
    ) {
        self.id = id
        self.line = line
        self.boardingStop = boardingStop
        self.alightingStop = alightingStop
        self.walkToBoardMinutes = walkToBoardMinutes
        self.walkFromAlightMinutes = walkFromAlightMinutes
        self.busRideMinutes = busRideMinutes
        self.waitMinutes = waitMinutes
        self.totalMinutes = totalMinutes
        self.fareCents = fareCents
        self.steps = steps
    }

    public var formattedFare: String {
        let reais = Double(fareCents) / 100.0
        return String(format: "R$ %.2f", reais)
    }
}
