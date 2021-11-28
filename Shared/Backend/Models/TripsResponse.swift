//
//  TripsResponse.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 12/07/20.
//

import Foundation

struct TripsResponse: Codable {
    let trips: [Trip]
}


struct PositionsResponse: Codable {
    var hour: String
    var vehicles: [Vehicle]?
    
    enum CodingKeys: String, CodingKey {
        case hour = "hr"
        case vehicles = "vs"
    }
}
