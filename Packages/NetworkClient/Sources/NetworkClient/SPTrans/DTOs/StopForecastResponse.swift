//
//  StopForecastResponse.swift
//  NetworkClient
//

import Foundation
import WIMBCore

/// Resposta do endpoint de previsão para uma parada específica.
public struct StopForecastResponse: Decodable, Sendable {
    public let hour: String
    public let detail: StopDetail

    enum CodingKeys: String, CodingKey {
        case hour = "hr"
        case stopPayload = "p"
    }

    enum StopPayloadKeys: String, CodingKey {
        case cp, np, py, px, vs, l
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hour = try container.decode(String.self, forKey: .hour)

        let payload = try container.nestedContainer(keyedBy: StopPayloadKeys.self, forKey: .stopPayload)
        let stop = try Stop(from: payload)

        if payload.contains(.l) {
            let linePayloads = try payload.decode([LineAtStopPayload].self, forKey: .l)
            let lines = linePayloads.map { linePayload in
                StopLineForecast(line: linePayload.line, vehicles: linePayload.vehicles ?? [])
            }
            detail = StopDetail(stop: stop, lines: lines, queryHour: hour)
        } else {
            let vehicles = try payload.decodeIfPresent([Vehicle].self, forKey: .vs) ?? []
            let lines = Self.linesFromFlatVehicles(vehicles, fallbackStop: stop)
            detail = StopDetail(stop: stop, lines: lines, queryHour: hour)
        }
    }

    public var stop: Stop { detail.stop }

    private struct LineAtStopPayload: Decodable {
        let line: TransportLine
        let vehicles: [Vehicle]?

        enum CodingKeys: String, CodingKey {
            case vehicles = "vs"
        }

        init(from decoder: Decoder) throws {
            line = try TransportLine(from: decoder)
            let container = try decoder.container(keyedBy: CodingKeys.self)
            vehicles = try container.decodeIfPresent([Vehicle].self, forKey: .vehicles)
        }
    }

    private static func linesFromFlatVehicles(_ vehicles: [Vehicle], fallbackStop: Stop) -> [StopLineForecast] {
        guard !vehicles.isEmpty else { return [] }

        var grouped: [String: [Vehicle]] = [:]
        for vehicle in vehicles {
            grouped[vehicle.prefix, default: []].append(vehicle)
        }

        return grouped.enumerated().map { index, entry in
            let line = TransportLine(
                id: fallbackStop.id * 10_000 + index,
                firstPartOfSign: entry.key,
                secondPartOfSign: 0,
                direction: 1,
                mainTerminal: fallbackStop.name,
                secondaryTerminal: fallbackStop.name,
                circular: false
            )
            return StopLineForecast(line: line, vehicles: entry.value)
        }
    }
}

private extension Stop {
    init(from container: KeyedDecodingContainer<StopForecastResponse.StopPayloadKeys>) throws {
        let id = try container.decode(Int.self, forKey: .cp)
        let name = try container.decode(String.self, forKey: .np)
        let lat = try container.decode(Double.self, forKey: .py)
        let lon = try container.decode(Double.self, forKey: .px)
        let vehicles = try container.decodeIfPresent([Vehicle].self, forKey: .vs)

        self.init(
            id: id,
            name: name,
            coordinate: Coordinate(latitude: lat, longitude: lon),
            vehicles: vehicles
        )
    }
}
