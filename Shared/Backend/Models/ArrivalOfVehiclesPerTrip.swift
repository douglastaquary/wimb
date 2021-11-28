//
//  ArrivalOfVehiclesPerTrip.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 14/07/20.
//

import SwiftUI
import CoreLocation
import MapKit

struct ArrivalOfVehiclesPerTrip: Codable, Identifiable {
    var id = UUID()
    let updatedTime: String
    let stops: [StopBus]?

    enum CodingKeys: String, CodingKey {
        case updatedTime = "hr"
        case stops = "ps"
    }
}
