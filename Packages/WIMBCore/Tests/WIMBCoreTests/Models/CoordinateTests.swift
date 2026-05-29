//
//  CoordinateTests.swift
//  WIMBCoreTests
//
//  Created by WIMB Team on 2026-05-21.
//

import XCTest
@testable import WIMBCore

final class CoordinateTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func test_init_setsLatitudeAndLongitude() {
        let coordinate = Coordinate(latitude: -23.55, longitude: -46.63)
        
        XCTAssertEqual(coordinate.latitude, -23.55)
        XCTAssertEqual(coordinate.longitude, -46.63)
    }
    
    // MARK: - CLLocationCoordinate2D Conversion
    
    func test_clCoordinate_convertsCorrectly() {
        let coordinate = Coordinate(latitude: -23.55, longitude: -46.63)
        let clCoord = coordinate.clCoordinate
        
        XCTAssertEqual(clCoord.latitude, -23.55)
        XCTAssertEqual(clCoord.longitude, -46.63)
    }
    
    // MARK: - Bearing Tests
    
    func test_bearing_toNorth_returnsZero() {
        let origin = Coordinate(latitude: -23.55, longitude: -46.63)
        let north = Coordinate(latitude: -23.50, longitude: -46.63)
        
        let bearing = origin.bearing(to: north)
        
        XCTAssertEqual(bearing, 0.0, accuracy: 0.001)
    }
    
    func test_bearing_toSouth_returnsPi() {
        let origin = Coordinate(latitude: -23.55, longitude: -46.63)
        let south = Coordinate(latitude: -23.60, longitude: -46.63)
        
        let bearing = origin.bearing(to: south)
        
        XCTAssertEqual(bearing, .pi, accuracy: 0.001)
    }
    
    func test_bearing_toEast_returnsHalfPi() {
        let origin = Coordinate(latitude: -23.55, longitude: -46.63)
        let east = Coordinate(latitude: -23.55, longitude: -46.60)
        
        let bearing = origin.bearing(to: east)
        
        XCTAssertEqual(bearing, .pi / 2, accuracy: 0.1)
    }
    
    // MARK: - Truncate Tests
    
    func test_truncated_reducesDecimalPlaces() {
        let coordinate = Coordinate(latitude: -23.123456789, longitude: -46.987654321)
        let truncated = coordinate.truncated(places: 4)
        
        XCTAssertEqual(truncated.latitude, -23.1234, accuracy: 0.0001)
        XCTAssertEqual(truncated.longitude, -46.9876, accuracy: 0.0001)
    }
    
    func test_truncated_default6Places() {
        let coordinate = Coordinate(latitude: -23.123456789, longitude: -46.987654321)
        let truncated = coordinate.truncated()
        
        XCTAssertEqual(truncated.latitude, -23.123456, accuracy: 0.000001)
        XCTAssertEqual(truncated.longitude, -46.987654, accuracy: 0.000001)
    }
    
    // MARK: - Distance Tests
    
    func test_distance_samePoint_returnsZero() {
        let coordinate = Coordinate(latitude: -23.55, longitude: -46.63)
        
        let distance = coordinate.distance(to: coordinate)
        
        XCTAssertEqual(distance, 0.0, accuracy: 0.1)
    }
    
    func test_distance_differentPoints_returnsPositive() {
        let praçaDaSé = Coordinate.saoPauloDefault
        let paulista = Coordinate(latitude: -23.561414, longitude: -46.655882)
        
        let distance = praçaDaSé.distance(to: paulista)
        
        XCTAssertGreaterThan(distance, 0)
        XCTAssertLessThan(distance, 5000) // Menos de 5km
    }
    
    // MARK: - Equatable Tests
    
    func test_equatable_sameCoordinates_returnsTrue() {
        let coord1 = Coordinate(latitude: -23.55, longitude: -46.63)
        let coord2 = Coordinate(latitude: -23.55, longitude: -46.63)
        
        XCTAssertEqual(coord1, coord2)
    }
    
    func test_equatable_differentCoordinates_returnsFalse() {
        let coord1 = Coordinate(latitude: -23.55, longitude: -46.63)
        let coord2 = Coordinate(latitude: -23.56, longitude: -46.64)
        
        XCTAssertNotEqual(coord1, coord2)
    }
    
    // MARK: - Hashable Tests
    
    func test_hashable_sameCoordinates_samHash() {
        let coord1 = Coordinate(latitude: -23.55, longitude: -46.63)
        let coord2 = Coordinate(latitude: -23.55, longitude: -46.63)
        
        XCTAssertEqual(coord1.hashValue, coord2.hashValue)
    }
    
    // MARK: - Static Constants Tests
    
    func test_saoPauloDefault_isCorrect() {
        let sp = Coordinate.saoPauloDefault
        
        XCTAssertEqual(sp.latitude, -23.550520, accuracy: 0.000001)
        XCTAssertEqual(sp.longitude, -46.633308, accuracy: 0.000001)
    }
    
    func test_zero_isZero() {
        let zero = Coordinate.zero
        
        XCTAssertEqual(zero.latitude, 0.0)
        XCTAssertEqual(zero.longitude, 0.0)
    }
}
