//
//  ArrivalOfVehiclesPerTrip.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 14/07/20.
//

import Foundation

struct ArrivalOfVehiclesPerTrip: Codable, Identifiable {
    var id = UUID()
    let updatedTime: String
    let vehicles: [Vehicle]

    enum CodingKeys: String, CodingKey {
        case updatedTime = "hr"
        case vehicles = "vs"
    }
}
