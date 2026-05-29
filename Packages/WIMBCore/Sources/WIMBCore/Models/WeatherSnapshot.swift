//
//  WeatherSnapshot.swift
//  WIMBCore
//

import Foundation

/// Condição climática atual usada para ajustar previsões de chegada.
public struct WeatherSnapshot: Sendable, Hashable {
    public enum Condition: String, Sendable, Hashable, Codable {
        case clear
        case cloudy
        case rain
        case heavyRain
        case fog
    }

    public let condition: Condition
    public let temperatureCelsius: Double
    public let trafficSpeedFactor: Double

    public init(
        condition: Condition,
        temperatureCelsius: Double,
        trafficSpeedFactor: Double
    ) {
        self.condition = condition
        self.temperatureCelsius = temperatureCelsius
        self.trafficSpeedFactor = min(1, max(0.4, trafficSpeedFactor))
    }

    /// Fator aplicado à velocidade urbana base (ex.: chuva reduz ~22%).
    public static func speedFactor(for condition: Condition) -> Double {
        switch condition {
        case .clear: return 1.0
        case .cloudy: return 0.95
        case .rain: return 0.78
        case .heavyRain: return 0.58
        case .fog: return 0.85
        }
    }
}
