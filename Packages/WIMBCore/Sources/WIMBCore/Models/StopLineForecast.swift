//
//  StopLineForecast.swift
//  WIMBCore
//

import Foundation

/// Linha com veículos previstos em uma parada.
public struct StopLineForecast: Sendable, Identifiable, Hashable {
    public let line: TransportLine
    public let vehicles: [Vehicle]

    public var id: Int { line.id }

    public init(line: TransportLine, vehicles: [Vehicle]) {
        self.line = line
        self.vehicles = vehicles
    }
}

/// Detalhe completo de uma parada (previsões por linha).
public struct StopDetail: Sendable {
    public let stop: Stop
    public let lines: [StopLineForecast]
    public let queryHour: String?

    public init(stop: Stop, lines: [StopLineForecast], queryHour: String? = nil) {
        self.stop = stop
        self.lines = lines
        self.queryHour = queryHour
    }
}
