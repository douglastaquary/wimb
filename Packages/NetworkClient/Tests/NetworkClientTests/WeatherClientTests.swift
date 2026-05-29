//
//  WeatherClientTests.swift
//  NetworkClientTests
//

import XCTest
@testable import NetworkClient
import WIMBCore

final class WeatherClientTests: XCTestCase {
    func test_currentWeather_parsesOpenMeteoResponse() async throws {
        let json = """
        {
          "current": {
            "weather_code": 61,
            "temperature_2m": 21.4
          }
        }
        """.data(using: .utf8)!

        let mock = MockHTTPClient()
        mock.setResponse(
            json,
            statusCode: 200,
            for: URL(string: "https://api.open-meteo.com/v1/forecast")!
        )

        let client = WeatherClient(httpClient: mock)
        let weather = try await client.currentWeather(
            at: Coordinate(latitude: -23.55, longitude: -46.63)
        )

        XCTAssertEqual(weather.condition, .rain)
        XCTAssertEqual(weather.temperatureCelsius, 21.4, accuracy: 0.01)
        XCTAssertLessThan(weather.trafficSpeedFactor, 1)
    }
}
