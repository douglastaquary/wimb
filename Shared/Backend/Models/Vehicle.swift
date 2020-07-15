//
//  Vehicle.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 13/07/20.
//

import Foundation
import CoreLocation

struct Vehicle: Codable, Identifiable {
    var id = UUID()
    let vehiclePrefix: Int
    let arrivalForecast: String
    let hasAccessibility: Bool
    let lastUpdatedTime: String
    let longitude: Double
    let latitude: Double
    
    enum CodingKeys: String, CodingKey {
        case vehiclePrefix = "p"
        case arrivalForecast = "t"
        case hasAccessibility = "a"
        case lastUpdatedTime = "ta"
        case longitude = "py"
        case latitude = "px"
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
