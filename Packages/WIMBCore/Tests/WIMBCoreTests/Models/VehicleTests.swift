//
//  VehicleTests.swift
//  WIMBCoreTests
//
//  Created by WIMB Team on 2026-05-21.
//

import XCTest
@testable import WIMBCore

final class VehicleTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func test_init_setsAllProperties() {
        let coordinate = Coordinate(latitude: -23.55, longitude: -46.63)
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: coordinate,
            arrivalForecast: "5 min"
        )
        
        XCTAssertEqual(vehicle.prefix, "74512")
        XCTAssertTrue(vehicle.accessible)
        XCTAssertEqual(vehicle.lastUpdateTime, "14:30")
        XCTAssertEqual(vehicle.coordinate, coordinate)
        XCTAssertNil(vehicle.previousCoordinate)
        XCTAssertEqual(vehicle.arrivalForecast, "5 min")
    }
    
    // MARK: - Update Position Tests
    
    func test_updatePosition_storesPreviousCoordinate() {
        let initialCoord = Coordinate(latitude: -23.55, longitude: -46.63)
        var vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: initialCoord
        )
        
        let newCoord = Coordinate(latitude: -23.56, longitude: -46.64)
        vehicle.updatePosition(to: newCoord)
        
        XCTAssertEqual(vehicle.coordinate, newCoord)
        XCTAssertEqual(vehicle.previousCoordinate, initialCoord)
    }
    
    func test_withUpdatedPosition_returnsNewVehicle() {
        let initialCoord = Coordinate(latitude: -23.55, longitude: -46.63)
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: initialCoord
        )
        
        let newCoord = Coordinate(latitude: -23.56, longitude: -46.64)
        let updatedVehicle = vehicle.withUpdatedPosition(newCoord)
        
        XCTAssertEqual(updatedVehicle.coordinate, newCoord)
        XCTAssertEqual(updatedVehicle.previousCoordinate, initialCoord)
        XCTAssertEqual(vehicle.coordinate, initialCoord) // Original unchanged
    }
    
    // MARK: - Heading Tests
    
    func test_heading_withoutPreviousCoordinate_returnsZero() {
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: Coordinate(latitude: -23.55, longitude: -46.63)
        )
        
        XCTAssertEqual(vehicle.heading, 0.0)
    }
    
    func test_heading_withPreviousCoordinate_calculatesCorrectly() {
        let previousCoord = Coordinate(latitude: -23.55, longitude: -46.63)
        let currentCoord = Coordinate(latitude: -23.54, longitude: -46.63)
        
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: currentCoord,
            previousCoordinate: previousCoord
        )
        
        XCTAssertEqual(vehicle.heading, 0.0, accuracy: 0.001) // Moving north
    }
    
    // MARK: - HasMoved Tests
    
    func test_hasMoved_withoutPreviousCoordinate_returnsFalse() {
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: Coordinate(latitude: -23.55, longitude: -46.63)
        )
        
        XCTAssertFalse(vehicle.hasMoved)
    }
    
    func test_hasMoved_samePosition_returnsFalse() {
        let coord = Coordinate(latitude: -23.55, longitude: -46.63)
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: coord,
            previousCoordinate: coord
        )
        
        XCTAssertFalse(vehicle.hasMoved)
    }
    
    func test_hasMoved_differentPosition_returnsTrue() {
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: Coordinate(latitude: -23.56, longitude: -46.64),
            previousCoordinate: Coordinate(latitude: -23.55, longitude: -46.63)
        )
        
        XCTAssertTrue(vehicle.hasMoved)
    }
    
    // MARK: - Display Properties Tests
    
    func test_displayTitle_returnsPrefix() {
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: Coordinate(latitude: -23.55, longitude: -46.63)
        )
        
        XCTAssertEqual(vehicle.displayTitle, "74512")
    }
    
    func test_displaySubtitle_withForecast_returnsForecast() {
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: Coordinate(latitude: -23.55, longitude: -46.63),
            arrivalForecast: "5 min"
        )
        
        XCTAssertEqual(vehicle.displaySubtitle, "Chegada: 5 min")
    }
    
    func test_displaySubtitle_withoutForecast_returnsUpdateTime() {
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: Coordinate(latitude: -23.55, longitude: -46.63)
        )
        
        XCTAssertEqual(vehicle.displaySubtitle, "Atualizado: 14:30")
    }
    
    // MARK: - Codable Tests

    func test_stableID_isDeterministicForPrefix() {
        let first = Vehicle.stableID(prefix: "36598")
        let second = Vehicle.stableID(prefix: "36598")
        let other = Vehicle.stableID(prefix: "74512")

        XCTAssertEqual(first, second)
        XCTAssertNotEqual(first, other)
    }

    func test_decode_fromAPIJSON_success() throws {
        let json = """
        {
            "p": "74512",
            "a": true,
            "ta": "2026-05-21T14:30:00Z",
            "py": -23.55,
            "px": -46.63,
            "t": "5 min"
        }
        """.data(using: .utf8)!
        
        let vehicle = try JSONDecoder().decode(Vehicle.self, from: json)
        
        XCTAssertEqual(vehicle.prefix, "74512")
        XCTAssertEqual(vehicle.id, Vehicle.stableID(prefix: "74512"))
        XCTAssertTrue(vehicle.accessible)
        XCTAssertEqual(vehicle.coordinate.latitude, -23.55)
        XCTAssertEqual(vehicle.coordinate.longitude, -46.63)
        XCTAssertEqual(vehicle.arrivalForecast, "5 min")
    }
    
    func test_decode_withoutForecast_success() throws {
        let json = """
        {
            "p": "74512",
            "a": false,
            "ta": "14:30",
            "py": -23.55,
            "px": -46.63
        }
        """.data(using: .utf8)!
        
        let vehicle = try JSONDecoder().decode(Vehicle.self, from: json)
        
        XCTAssertEqual(vehicle.prefix, "74512")
        XCTAssertFalse(vehicle.accessible)
        XCTAssertNil(vehicle.arrivalForecast)
    }
    
    func test_encode_toJSON_success() throws {
        let vehicle = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: Coordinate(latitude: -23.55, longitude: -46.63),
            arrivalForecast: "5 min"
        )
        
        let data = try JSONEncoder().encode(vehicle)
        let decoded = try JSONDecoder().decode(Vehicle.self, from: data)
        
        XCTAssertEqual(decoded.prefix, vehicle.prefix)
        XCTAssertEqual(decoded.accessible, vehicle.accessible)
        XCTAssertEqual(decoded.coordinate, vehicle.coordinate)
    }
}
