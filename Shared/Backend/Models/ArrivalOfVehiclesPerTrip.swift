//
//  ArrivalOfVehiclesPerTrip.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 14/07/20.
//

import Foundation
import CoreLocation
import MapKit

struct ArrivalOfVehiclesPerTrip: Codable, Identifiable {
    var id = UUID()
    let updatedTime: String
    let stops: [StopBus]

    enum CodingKeys: String, CodingKey {
        case updatedTime = "hr"
        case stops = "ps"
    }
}


class StopBus: NSObject, Codable, Identifiable {
    var id = UUID()
    let stopId: Int
    let descript: String
    let addrees: String
    let longitude: Double
    let latitude: Double
    //let vehicles: [Vehicle]
    
    public var title: String? {
        return descript
    }

    enum CodingKeys: String, CodingKey {
        case stopId = "cp"
        case descript = "np"
        case addrees = "ed"
        case longitude = "px"
        case latitude = "py"
        //case vehicles = "vs"
    }

}

extension StopBus: MKAnnotation {

    public var subtitle: String? {
        return addrees
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

}
