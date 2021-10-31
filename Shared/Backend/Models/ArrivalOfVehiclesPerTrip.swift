//
//  ArrivalOfVehiclesPerTrip.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 14/07/20.
//

import Foundation
import CoreLocation

struct ArrivalOfVehiclesPerTrip: Codable, Identifiable {
    var id = UUID()
    let updatedTime: String
    let stops: [StopBus]?

    enum CodingKeys: String, CodingKey {
        case updatedTime = "hr"
        case stops = "ps"
    }
}


struct StopBus: Codable, Identifiable {
    var id = UUID()
    let stopId: Int
    let descript: String
    let longitude: Double
    let latitude: Double
    let vehicles: [Vehicle]?

    enum CodingKeys: String, CodingKey {
        case stopId = "cp"
        case descript = "np"
        case longitude = "py"
        case latitude = "px"
        case vehicles = "vs"
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
