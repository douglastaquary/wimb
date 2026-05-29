//
//  ArrivalPredictorTests.swift
//  TransportEngineTests
//

import XCTest
@testable import TransportEngine
import WIMBCore

final class ArrivalPredictorTests: XCTestCase {
    func test_predict_returnsPositiveMinutes() {
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: Coordinate(latitude: -23.55, longitude: -46.63)
        )

        let destination = Coordinate(latitude: -23.56, longitude: -46.64)
        let prediction = SimpleArrivalPredictor().predict(
            vehicle: vehicle,
            to: destination,
            context: PredictionContext()
        )

        XCTAssertEqual(prediction.vehiclePrefix, "74512")
        XCTAssertGreaterThan(prediction.estimatedMinutes, 0)
        XCTAssertGreaterThan(prediction.distanceMeters, 0)
    }

    func test_smartPredictor_usesSpTransForecast() {
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: Coordinate(latitude: -23.55, longitude: -46.63),
            arrivalForecast: "4 min"
        )

        let prediction = SmartArrivalPredictor().predict(
            vehicle: vehicle,
            to: Coordinate(latitude: -23.551, longitude: -46.631),
            context: PredictionContext(spTransForecast: vehicle.arrivalForecast)
        )

        XCTAssertEqual(prediction.estimatedMinutes, 4)
        XCTAssertEqual(prediction.source, .spTrans)
    }

    func test_smartPredictor_adjustsForRain() {
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: Coordinate(latitude: -23.55, longitude: -46.63)
        )

        let destination = Coordinate(latitude: -23.56, longitude: -46.64)
        let clear = SimpleArrivalPredictor().predict(
            vehicle: vehicle,
            to: destination,
            context: PredictionContext(weather: WeatherSnapshot(condition: .clear, temperatureCelsius: 24, trafficSpeedFactor: 1))
        )
        let rain = SmartArrivalPredictor().predict(
            vehicle: vehicle,
            to: destination,
            context: PredictionContext(weather: WeatherSnapshot(condition: .rain, temperatureCelsius: 20, trafficSpeedFactor: 0.78))
        )

        XCTAssertGreaterThanOrEqual(rain.estimatedMinutes, clear.estimatedMinutes)
    }
}

final class SPTransForecastParserTests: XCTestCase {
    func test_parsesMinutes() {
        XCTAssertEqual(SPTransForecastParser.minutes(from: "3 min"), 3)
        XCTAssertEqual(SPTransForecastParser.minutes(from: "Chegando"), 1)
    }
}

final class MetroNearbyServiceTests: XCTestCase {
    func test_findsNearbyStations() {
        let service = MetroNearbyService()
        let stops = service.nearbyStations(to: Coordinate.saoPauloDefault, limit: 2)

        XCTAssertFalse(stops.isEmpty)
        XCTAssertLessThanOrEqual(stops.count, 2)
    }

    func test_simulatorLocationOutsideSP_fallsBackToSaoPaulo() {
        let service = MetroNearbyService()
        // Cupertino — fora da região SPTrans/metrô.
        let cupertino = Coordinate(latitude: 37.3349, longitude: -122.0090)
        let stops = service.nearbyStations(to: cupertino, limit: 3)

        XCTAssertFalse(stops.isEmpty)
        XCTAssertTrue(stops.contains { $0.station.name == "Sé" })
    }
}
