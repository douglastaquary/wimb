//
//  Trip.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 13/07/20.
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
    
    static func tripMock() -> Trip {
        return Trip(tripId: 1111, withoutSecondaryTerminal: true, firstPartOfTheSign: "8000", secondPartOfTheSign: 10, travelDestination: 1, mainTerminal: "Vicente Rao", secondaryTerminal: "Metro conceição")
    }
}
