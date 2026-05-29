//
//  RouteSuggestionEngine.swift
//  TransportEngine
//

import Foundation
import WIMBCore

/// Motor heurístico de rotas A→B com linhas SPTrans (MVP Fase 6.5).
public struct RouteSuggestionEngine: Sendable {
    public static let defaultWalkingSpeedMps: Double = 1.4
    public static let defaultStopIntervalMinutes: Int = 2
    public static let defaultWaitMinutes: Int = 8
    public static let bilheteUnicoFareCents: Int = 440
    public static let maxSuggestions: Int = 5
    public static let maxCandidateLines: Int = 12
    public static let maxWalkRadiusMeters: Double = 800

    private let client: TransportService
    private let predictor: SmartArrivalPredictor

    public init(
        client: TransportService,
        predictor: SmartArrivalPredictor = SmartArrivalPredictor()
    ) {
        self.client = client
        self.predictor = predictor
    }

    public func suggest(
        from origin: Coordinate,
        to destination: Coordinate,
        context: PredictionContext = PredictionContext()
    ) async throws -> [RouteSuggestion] {
        let candidates = try await collectCandidateLines(near: origin, fallbackNear: destination)
        var suggestions: [RouteSuggestion] = []

        for line in candidates.prefix(Self.maxCandidateLines) {
            if let suggestion = try await evaluate(
                line: line,
                origin: origin,
                destination: destination,
                context: context
            ) {
                suggestions.append(suggestion)
            }
        }

        return suggestions
            .sorted { $0.totalMinutes < $1.totalMinutes }
            .prefix(Self.maxSuggestions)
            .map { $0 }
    }

    private func collectCandidateLines(
        near origin: Coordinate,
        fallbackNear destination: Coordinate
    ) async throws -> [TransportLine] {
        var lines: [TransportLine] = []
        var seen = Set<Int>()

        let originQuery = await ReverseGeocoder.streetQuery(for: origin)
        let originStops = try await client.fetchNearbyStops(
            near: origin,
            query: originQuery,
            radiusMeters: Self.maxWalkRadiusMeters
        )

        await appendLines(from: originStops, into: &lines, seen: &seen)

        if lines.isEmpty {
            let destQuery = await ReverseGeocoder.streetQuery(for: destination)
            let destStops = try await client.fetchNearbyStops(
                near: destination,
                query: destQuery,
                radiusMeters: Self.maxWalkRadiusMeters
            )
            await appendLines(from: destStops, into: &lines, seen: &seen)
        }

        return lines
    }

    private func appendLines(
        from stops: [Stop],
        into lines: inout [TransportLine],
        seen: inout Set<Int>
    ) async {
        for stop in stops.prefix(4) {
            guard let detail = try? await client.fetchStopDetail(stopId: stop.id) else { continue }

            for forecast in detail.lines {
                if seen.insert(forecast.line.id).inserted {
                    lines.append(forecast.line)
                }
            }

            if lines.count >= Self.maxCandidateLines { break }
        }
    }

    private func evaluate(
        line: TransportLine,
        origin: Coordinate,
        destination: Coordinate,
        context: PredictionContext
    ) async throws -> RouteSuggestion? {
        let stops = try await client.fetchArrivals(lineId: line.id)
        guard stops.count >= 2 else { return nil }

        guard let boardIndex = bestStopIndex(
            in: stops,
            near: origin,
            maxRadius: Self.maxWalkRadiusMeters
        ) else {
            return nil
        }

        let afterBoarding = Array(stops[(boardIndex + 1)...])
        guard let alightOffset = bestStopIndex(
            in: afterBoarding,
            near: destination,
            maxRadius: Self.maxWalkRadiusMeters * 1.5
        ) else {
            return nil
        }

        let alightIndex = boardIndex + 1 + alightOffset
        let boarding = stops[boardIndex]
        let alighting = stops[alightIndex]

        let walkToBoard = walkingMinutes(from: origin, to: boarding.coordinate)
        let walkFromAlight = walkingMinutes(from: alighting.coordinate, to: destination)
        let waitMinutes = waitTime(at: boarding, context: context)
        let stopCount = alightIndex - boardIndex
        let busRide = max(1, stopCount * Self.defaultStopIntervalMinutes)
        let total = walkToBoard + waitMinutes + busRide + walkFromAlight

        let steps: [RouteStep] = [
            RouteStep(
                kind: .walk,
                title: boarding.displayTitle,
                subtitle: nil,
                durationMinutes: walkToBoard
            ),
            RouteStep(
                kind: .bus,
                title: line.formattedNumber,
                subtitle: line.routeDescription,
                durationMinutes: waitMinutes + busRide
            ),
            RouteStep(
                kind: .walk,
                title: alighting.displayTitle,
                subtitle: nil,
                durationMinutes: walkFromAlight
            )
        ]

        return RouteSuggestion(
            line: line,
            boardingStop: boarding,
            alightingStop: alighting,
            walkToBoardMinutes: walkToBoard,
            walkFromAlightMinutes: walkFromAlight,
            busRideMinutes: busRide,
            waitMinutes: waitMinutes,
            totalMinutes: total,
            fareCents: Self.bilheteUnicoFareCents,
            steps: steps
        )
    }

    private func bestStopIndex(
        in stops: [Stop],
        near coordinate: Coordinate,
        maxRadius: Double
    ) -> Int? {
        var bestIndex: Int?
        var bestDistance = maxRadius

        for (index, stop) in stops.enumerated() {
            let distance = coordinate.distance(to: stop.coordinate)
            if distance <= bestDistance {
                bestDistance = distance
                bestIndex = index
            }
        }

        return bestIndex
    }

    private func walkingMinutes(from origin: Coordinate, to destination: Coordinate) -> Int {
        let meters = origin.distance(to: destination)
        let seconds = meters / Self.defaultWalkingSpeedMps
        return max(1, Int((seconds / 60).rounded()))
    }

    private func waitTime(at stop: Stop, context: PredictionContext) -> Int {
        guard let vehicles = stop.vehicles, !vehicles.isEmpty else {
            return Self.defaultWaitMinutes
        }

        let minutes = vehicles.map { vehicle in
            predictor.predict(vehicle: vehicle, to: stop.coordinate, context: context).estimatedMinutes
        }

        return minutes.min() ?? Self.defaultWaitMinutes
    }
}
