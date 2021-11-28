//
//  StopBus.swift
//  iOS
//
//  Created by Douglas Taquary on 28/11/21.
//

import SwiftUI
import CoreLocation
import MapKit

enum AnnotationType {
    case bus
    case stop
    
    var symbol: some View {
        switch self {
        case .bus:
            return Image(systemName: "bus").foregroundColor(.blue)
        case .stop:
            return Image(systemName: "figure.wave.circle.fill").foregroundColor(.green)
        }
    }
}

struct StopBus: Codable, MapAnnotationItem {
    
    var id = UUID()
    let stopId: Int
    let descript: String
    let longitude: Double
    let latitude: Double
    let vehicles: [Vehicle]?
    var annotationType: AnnotationType? = .stop
    
    public init(stopId: Int, descript: String, longitude: Double, latitude: Double, vehicles: [Vehicle]?) {
        self.stopId = stopId
        self.descript = descript
        self.longitude = longitude
        self.latitude = latitude
        self.vehicles = vehicles
    }

    enum CodingKeys: String, CodingKey {
        case stopId = "cp"
        case descript = "np"
        case longitude = "px"
        case latitude = "py"
        case vehicles = "vs"
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var annotation: some MapAnnotationProtocol {
        return MapAnnotation(coordinate: coordinate) {
            ZStack(alignment: .center) {
                Circle()
                    .foregroundColor(.clear)
                    .frame(width: 30, height: 30, alignment: .center)
                annotationType?.symbol
            }
            .scaleEffect(1.5, anchor: .center)
        }
    }
}


