//
//  VehiclePositionResponse.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 16/07/20.
//

import Foundation

struct VehiclePositionResponse: Codable {
    let lastUpdatedTime: String
    let vehicles: [Vehicle]
    
    enum CodingKeys: String, CodingKey {
        case lastUpdatedTime = "hr"
        case vehicles = "vs"
    }
}
