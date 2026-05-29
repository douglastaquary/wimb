//
//  SmartArrivalPredictor.swift
//  TransportEngine
//

import Foundation
import WIMBCore

/// Previsão que combina dados da SPTrans, movimento do veículo e clima.
public struct SmartArrivalPredictor: ArrivalPredicting {
    private let fallback: SimpleArrivalPredictor

    public init(fallback: SimpleArrivalPredictor = SimpleArrivalPredictor()) {
        self.fallback = fallback
    }

    public func predict(
        vehicle: Vehicle,
        to destination: Coordinate,
        context: PredictionContext
    ) -> ArrivalPrediction {
        if let spMinutes = context.spTransForecast.flatMap({ SPTransForecastParser.minutes(from: $0) }) {
            let distance = vehicle.coordinate.distance(to: destination)
            return ArrivalPrediction(
                vehiclePrefix: vehicle.prefix,
                estimatedMinutes: spMinutes,
                distanceMeters: distance,
                averageSpeedKmh: inferredSpeedKmh(distance: distance, minutes: spMinutes),
                source: .spTrans
            )
        }

        let speedKmh = blendedSpeed(for: vehicle, weather: context.weather)
        let estimated = fallback.makePrediction(
            vehicle: vehicle,
            to: destination,
            speedKmh: speedKmh,
            source: .estimated
        )

        if context.weather != nil {
            return ArrivalPrediction(
                vehiclePrefix: estimated.vehiclePrefix,
                estimatedMinutes: estimated.estimatedMinutes,
                distanceMeters: estimated.distanceMeters,
                averageSpeedKmh: estimated.averageSpeedKmh,
                source: .hybrid
            )
        }

        return estimated
    }

    private func blendedSpeed(for vehicle: Vehicle, weather: WeatherSnapshot?) -> Double {
        let weatherFactor = weather?.trafficSpeedFactor ?? 1
        let baseSpeed = SimpleArrivalPredictor.defaultUrbanSpeedKmh * weatherFactor

        guard let previous = vehicle.previousCoordinate else {
            return baseSpeed
        }

        let movedMeters = previous.distance(to: vehicle.coordinate)
        guard movedMeters > 5 else { return baseSpeed }

        // Assume intervalo típico de polling (~10s) para estimar velocidade instantânea.
        let observedKmh = min(45, max(5, (movedMeters / 10) * 3.6))
        return (observedKmh * 0.35) + (baseSpeed * 0.65)
    }

    private func inferredSpeedKmh(distance: Double, minutes: Int) -> Double {
        guard minutes > 0 else { return SimpleArrivalPredictor.defaultUrbanSpeedKmh }
        let metersPerSecond = distance / Double(minutes * 60)
        return max(5, metersPerSecond * 3.6)
    }
}
