//
//  WeatherClient.swift
//  NetworkClient
//

import Foundation
import WIMBCore

/// Cliente de clima via [Open-Meteo](https://open-meteo.com/) — sem API key.
public struct WeatherClient: Sendable {
    private let httpClient: HTTPClient
    private let baseURL: URL

    public init(
        httpClient: HTTPClient = URLSessionHTTPClient(),
        baseURL: URL = URL(string: "https://api.open-meteo.com/v1/forecast")!
    ) {
        self.httpClient = httpClient
        self.baseURL = baseURL
    }

    public func currentWeather(at coordinate: Coordinate) async throws -> WeatherSnapshot {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "current", value: "weather_code,temperature_2m"),
            URLQueryItem(name: "timezone", value: "America/Sao_Paulo")
        ]

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        let request = URLRequest(url: url)
        let (data, response) = try await httpClient.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        if let error = NetworkError.from(statusCode: httpResponse.statusCode, data: data) {
            throw error
        }

        let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        let condition = mapWeatherCode(decoded.current.weatherCode)
        return WeatherSnapshot(
            condition: condition,
            temperatureCelsius: decoded.current.temperature2m,
            trafficSpeedFactor: WeatherSnapshot.speedFactor(for: condition)
        )
    }

    private func mapWeatherCode(_ code: Int) -> WeatherSnapshot.Condition {
        switch code {
        case 0: return .clear
        case 1...3, 51: return .cloudy
        case 45, 48: return .fog
        case 61...67, 80, 81: return .rain
        case 82, 95...99: return .heavyRain
        default: return .cloudy
        }
    }
}

private struct OpenMeteoResponse: Decodable {
    let current: OpenMeteoCurrent
}

private struct OpenMeteoCurrent: Decodable {
    let weatherCode: Int
    let temperature2m: Double

    enum CodingKeys: String, CodingKey {
        case weatherCode = "weather_code"
        case temperature2m = "temperature_2m"
    }
}
