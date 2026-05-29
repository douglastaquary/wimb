//
//  MockTransportService.swift
//  TransportEngineTests
//

import Foundation
import WIMBCore

actor MockTransportService: TransportService {
    var authenticateResult = true
    var searchLinesResult: [TransportLine] = []
    var vehiclePositionsResult: [Int: [Vehicle]] = [:]
    var arrivalsResult: [Int: [Stop]] = [:]
    var stopForecastResult: [Int: Stop] = [:]
    var stopDetailResult: [Int: StopDetail] = [:]
    var searchStopsResult: [Stop] = []

    var authenticateCalled = false
    var fetchVehiclePositionsCalled = false
    var searchStopsCalled = false
    var lastSearchStopsQuery: String?

    func authenticate() async throws -> Bool {
        authenticateCalled = true
        return authenticateResult
    }

    func searchLines(query: String) async throws -> [TransportLine] {
        searchLinesResult
    }

    var shouldFailFetch = false

    func fetchVehiclePositions(lineId: Int) async throws -> [Vehicle] {
        fetchVehiclePositionsCalled = true
        if shouldFailFetch {
            throw WIMBError.networkError(underlying: URLError(.notConnectedToInternet))
        }
        return vehiclePositionsResult[lineId] ?? []
    }

    func fetchArrivals(lineId: Int) async throws -> [Stop] {
        arrivalsResult[lineId] ?? []
    }

    func fetchStopForecast(stopId: Int) async throws -> Stop {
        guard let stop = stopForecastResult[stopId] else {
            throw WIMBError.stopNotFound(id: stopId)
        }
        return stop
    }

    func searchStops(query: String) async throws -> [Stop] {
        searchStopsCalled = true
        lastSearchStopsQuery = query
        return searchStopsResult
    }

    func fetchStopDetail(stopId: Int) async throws -> StopDetail {
        if let detail = stopDetailResult[stopId] {
            return detail
        }
        if let stop = stopForecastResult[stopId] {
            let lines = (stop.vehicles ?? []).map { vehicle in
                StopLineForecast(
                    line: TransportLine(
                        id: stopId,
                        firstPartOfSign: vehicle.prefix,
                        secondPartOfSign: 0,
                        direction: 1,
                        mainTerminal: stop.name,
                        secondaryTerminal: stop.name,
                        circular: false
                    ),
                    vehicles: [vehicle]
                )
            }
            return StopDetail(stop: stop, lines: lines)
        }
        throw WIMBError.stopNotFound(id: stopId)
    }

    func setVehiclePositions(_ vehicles: [Vehicle], for lineId: Int) {
        vehiclePositionsResult[lineId] = vehicles
    }

    func setShouldFailFetch(_ value: Bool) {
        shouldFailFetch = value
    }

    func setSearchStops(_ stops: [Stop]) {
        searchStopsResult = stops
    }

    func setArrivals(_ stops: [Stop], for lineId: Int) {
        arrivalsResult[lineId] = stops
    }

    func setStopDetail(_ detail: StopDetail, for stopId: Int) {
        stopDetailResult[stopId] = detail
    }
}
