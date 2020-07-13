//
//  TripsResponse.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 12/07/20.
//

import Foundation

struct Trip: Codable, Identifiable {
    var id = UUID()
    let tripId: Int
    let withoutSecondaryTerminal: Bool
    let firstPartOfTheSign: String
    let secondPartOfTheSign: Int
    let travelDestination: Int
    let mainTerminal: String
    let secondaryTerminal: String

    enum CodingKeys: String, CodingKey {
        case tripId = "cl"
        case withoutSecondaryTerminal = "lc"
        case firstPartOfTheSign = "lt"
        case secondPartOfTheSign = "tl"
        case travelDestination = "sl"
        case mainTerminal = "tp"
        case secondaryTerminal = "ts"
        
    }
}

struct TripsResponse: Codable {
    let trips: [Trip]
}
