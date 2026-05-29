//
//  SPTransClientTests.swift
//  NetworkClientTests
//
//  Created by WIMB Team on 2026-05-21.
//

import XCTest
@testable import NetworkClient
import WIMBCore

final class SPTransClientTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: SPTransClient!
    var mockHTTPClient: MockHTTPClient!
    var configuration: SPTransConfiguration!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        configuration = SPTransConfiguration(token: "test-token")
        sut = SPTransClient(configuration: configuration, httpClient: mockHTTPClient)
    }
    
    override func tearDown() {
        sut = nil
        mockHTTPClient = nil
        configuration = nil
        super.tearDown()
    }
    
    // MARK: - Authentication Tests
    
    func test_authenticate_success_returnsTrue() async throws {
        // Given
        mockHTTPClient.setTextResponse("true", for: MockResponses.authURL)
        
        // When
        let result = try await sut.authenticate()
        
        // Then
        XCTAssertTrue(result)
        let isAuthenticated = await sut.authenticated
        XCTAssertTrue(isAuthenticated)
    }
    
    func test_authenticate_failure_returnsFalse() async throws {
        // Given
        mockHTTPClient.setTextResponse("false", for: MockResponses.authURL)
        
        // When
        let result = try await sut.authenticate()
        
        // Then
        XCTAssertFalse(result)
        let isAuthenticated = await sut.authenticated
        XCTAssertFalse(isAuthenticated)
    }
    
    func test_authenticate_serverError_throwsError() async {
        // Given
        mockHTTPClient.setResponse(Data(), statusCode: 500, for: MockResponses.authURL)
        
        // When/Then
        do {
            _ = try await sut.authenticate()
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected serverError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Search Lines Tests
    
    func test_searchLines_returnsLines() async throws {
        // Given
        mockHTTPClient.setTextResponse("true", for: MockResponses.authURL)
        mockHTTPClient.setResponse(MockResponses.linesJSON, for: MockResponses.searchLinesURL)
        
        // When
        let lines = try await sut.searchLines(query: "8000")
        
        // Then
        XCTAssertEqual(lines.count, 2)
        XCTAssertEqual(lines[0].formattedNumber, "8000-10")
        XCTAssertEqual(lines[0].mainTerminal, "METRÔ JABAQUARA")
    }
    
    func test_searchLines_emptyResult_returnsEmptyArray() async throws {
        // Given
        mockHTTPClient.setTextResponse("true", for: MockResponses.authURL)
        mockHTTPClient.setResponse(MockResponses.emptyLinesJSON, for: MockResponses.searchLinesURL)
        
        // When
        let lines = try await sut.searchLines(query: "xyz")
        
        // Then
        XCTAssertTrue(lines.isEmpty)
    }
    
    // MARK: - Positions Tests
    
    func test_fetchVehiclePositions_returnsVehicles() async throws {
        // Given
        mockHTTPClient.setTextResponse("true", for: MockResponses.authURL)
        mockHTTPClient.setResponse(MockResponses.positionsJSON, for: MockResponses.positionsURL)
        
        // When
        let vehicles = try await sut.fetchVehiclePositions(lineId: 34041)
        
        // Then
        XCTAssertEqual(vehicles.count, 2)
        XCTAssertEqual(vehicles[0].prefix, "74512")
        XCTAssertTrue(vehicles[0].accessible)
        XCTAssertEqual(vehicles[0].coordinate.latitude, -23.660826, accuracy: 0.000001)
    }
    
    func test_fetchVehiclePositions_noVehicles_returnsEmptyArray() async throws {
        // Given
        mockHTTPClient.setTextResponse("true", for: MockResponses.authURL)
        mockHTTPClient.setResponse(MockResponses.emptyPositionsJSON, for: MockResponses.positionsURL)
        
        // When
        let vehicles = try await sut.fetchVehiclePositions(lineId: 34041)
        
        // Then
        XCTAssertTrue(vehicles.isEmpty)
    }
    
    // MARK: - Arrivals Tests
    
    func test_fetchArrivals_returnsStops() async throws {
        // Given
        mockHTTPClient.setTextResponse("true", for: MockResponses.authURL)
        mockHTTPClient.setResponse(MockResponses.arrivalsJSON, for: MockResponses.arrivalsURL)
        
        // When
        let stops = try await sut.fetchArrivals(lineId: 34041)
        
        // Then
        XCTAssertEqual(stops.count, 1)
        XCTAssertEqual(stops[0].name, "Av. Paulista, 1000")
        XCTAssertEqual(stops[0].vehicleCount, 1)
    }
    
    // MARK: - Stop Forecast Tests
    
    func test_fetchStopForecast_returnsStop() async throws {
        // Given
        mockHTTPClient.setTextResponse("true", for: MockResponses.authURL)
        mockHTTPClient.setResponse(MockResponses.stopForecastJSON, for: MockResponses.stopForecastURL)
        
        // When
        let stop = try await sut.fetchStopForecast(stopId: 12345)
        
        // Then
        XCTAssertEqual(stop.id, 12345)
        XCTAssertEqual(stop.name, "Av. Paulista, 1000")
        XCTAssertTrue(stop.hasVehicles)
    }

    func test_searchStops_returnsStops() async throws {
        mockHTTPClient.setTextResponse("true", for: MockResponses.authURL)
        mockHTTPClient.setResponse(MockResponses.searchStopsJSON, for: MockResponses.searchStopsURL)

        let stops = try await sut.searchStops(query: "Paulista")

        XCTAssertEqual(stops.count, 2)
        XCTAssertEqual(stops[0].id, 12345)
    }

    func test_fetchStopDetail_returnsLines() async throws {
        mockHTTPClient.setTextResponse("true", for: MockResponses.authURL)
        mockHTTPClient.setResponse(MockResponses.stopForecastJSON, for: MockResponses.stopForecastURL)

        let detail = try await sut.fetchStopDetail(stopId: 12345)

        XCTAssertEqual(detail.stop.id, 12345)
        XCTAssertFalse(detail.lines.isEmpty)
    }
    
    // MARK: - Auto-Auth Tests
    
    func test_searchLines_autoAuthenticates() async throws {
        // Given
        mockHTTPClient.setTextResponse("true", for: MockResponses.authURL)
        mockHTTPClient.setResponse(MockResponses.linesJSON, for: MockResponses.searchLinesURL)
        
        // Verify not authenticated initially
        let initiallyAuthenticated = await sut.authenticated
        XCTAssertFalse(initiallyAuthenticated)

        // When
        _ = try await sut.searchLines(query: "8000")

        // Then
        let authenticatedAfterSearch = await sut.authenticated
        XCTAssertTrue(authenticatedAfterSearch)
        
        // Verify auth was called
        let authRequests = mockHTTPClient.requestsReceived.filter {
            $0.url?.path.contains("Login") == true
        }
        XCTAssertEqual(authRequests.count, 1)
    }
    
    // MARK: - Reset Authentication Tests
    
    func test_resetAuthentication_resetsState() async throws {
        // Given
        mockHTTPClient.setTextResponse("true", for: MockResponses.authURL)
        _ = try await sut.authenticate()
        let authenticatedBeforeReset = await sut.authenticated
        XCTAssertTrue(authenticatedBeforeReset)

        // When
        await sut.resetAuthentication()

        // Then
        let authenticatedAfterReset = await sut.authenticated
        XCTAssertFalse(authenticatedAfterReset)
    }
}
