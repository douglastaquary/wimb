//
//  Vehicle.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 13/07/20.
//

import Foundation
import CoreLocation
import MapKit

class Vehicle: NSObject, Codable, Identifiable {
    var id = UUID()
    let vehiclePrefix: String
    //let arrivalForecast: String
    let hasAccessibility: Bool
    let lastUpdatedTime: String
    var longitude: Double
    var latitude: Double
    
    public var title: String? {
        return vehiclePrefix
    }
    
    enum CodingKeys: String, CodingKey {
        case vehiclePrefix = "p"
        //case arrivalForecast = "t"
        case hasAccessibility = "a"
        case lastUpdatedTime = "ta"
        case longitude = "px"
        case latitude = "py"
    }

}

extension Vehicle: MKAnnotation {
    
    public var subtitle: String? {
        return lastUpdatedTime
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

}
