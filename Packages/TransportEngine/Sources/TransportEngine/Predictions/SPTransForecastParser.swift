//
//  SPTransForecastParser.swift
//  TransportEngine
//

import Foundation

/// Interpreta textos de previsão retornados pela SPTrans.
enum SPTransForecastParser {
    static func minutes(from forecast: String) -> Int? {
        let normalized = forecast
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if normalized.contains("aproxim") || normalized.contains("chegando") {
            return 1
        }

        let digits = normalized
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()

        guard let value = Int(digits), value > 0 else {
            return nil
        }

        return min(value, 120)
    }
}
