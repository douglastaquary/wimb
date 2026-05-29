//
//  ArrivalPredictor.swift
//  TransportEngine
//

import Foundation
import WIMBCore

/// Previsão estimada de chegada de um veículo.
public struct ArrivalPrediction: Sendable, Hashable {
    public enum Source: String, Sendable, Hashable {
        case spTrans
        case estimated
        case hybrid
    }

    public let vehiclePrefix: String
    public let estimatedMinutes: Int
    public let distanceMeters: Double
    public let averageSpeedKmh: Double
    public let source: Source

    public init(
        vehiclePrefix: String,
        estimatedMinutes: Int,
        distanceMeters: Double,
        averageSpeedKmh: Double,
        source: Source = .estimated
    ) {
        self.vehiclePrefix = vehiclePrefix
        self.estimatedMinutes = estimatedMinutes
        self.distanceMeters = distanceMeters
        self.averageSpeedKmh = averageSpeedKmh
        self.source = source
    }
}

/// Contexto adicional para previsões inteligentes.
public struct PredictionContext: Sendable {
    public var weather: WeatherSnapshot?
    public var spTransForecast: String?

    public init(weather: WeatherSnapshot? = nil, spTransForecast: String? = nil) {
        self.weather = weather
        self.spTransForecast = spTransForecast
    }
}

/// Contrato para algoritmos de previsão de chegada.
public protocol ArrivalPredicting: Sendable {
    func predict(
        vehicle: Vehicle,
        to destination: Coordinate,
        context: PredictionContext
    ) -> ArrivalPrediction
}

/// Calcula ETA com base em distância e velocidade média urbana.
public struct SimpleArrivalPredictor: ArrivalPredicting {
    public static let defaultUrbanSpeedKmh: Double = 18

    public init() {}

    public func predict(
        vehicle: Vehicle,
        to destination: Coordinate,
        context: PredictionContext = PredictionContext()
    ) -> ArrivalPrediction {
        let speedKmh = adjustedSpeed(
            baseSpeedKmh: Self.defaultUrbanSpeedKmh,
            weather: context.weather
        )

        return makePrediction(
            vehicle: vehicle,
            to: destination,
            speedKmh: speedKmh,
            source: .estimated
        )
    }

    func adjustedSpeed(baseSpeedKmh: Double, weather: WeatherSnapshot?) -> Double {
        baseSpeedKmh * (weather?.trafficSpeedFactor ?? 1)
    }

    func makePrediction(
        vehicle: Vehicle,
        to destination: Coordinate,
        speedKmh: Double,
        source: ArrivalPrediction.Source
    ) -> ArrivalPrediction {
        let distance = vehicle.coordinate.distance(to: destination)
        let speedMetersPerSecond = max(speedKmh, 1) / 3.6
        let seconds = distance / speedMetersPerSecond
        let minutes = max(1, Int((seconds / 60).rounded()))

        return ArrivalPrediction(
            vehiclePrefix: vehicle.prefix,
            estimatedMinutes: minutes,
            distanceMeters: distance,
            averageSpeedKmh: speedKmh,
            source: source
        )
    }
}
