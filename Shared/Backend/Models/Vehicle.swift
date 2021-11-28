//
//  Vehicle.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 13/07/20.
//

import SwiftUI
import CoreLocation
import MapKit

struct Vehicle: Codable, MapAnnotationItem {
    
    public var id = UUID()
    let vehiclePrefix: String
    let arrivalForecast: String?
    let hasAccessibility: Bool
    let lastUpdatedTime: String
    let longitude: Double
    let latitude: Double
    
    var annotationType: AnnotationType? = .bus
    
    public init(vehiclePrefix: String, arrivalForecast: String, hasAccessibility: Bool, lastUpdatedTime: String, longitude: Double, latitude: Double) {
        self.vehiclePrefix = vehiclePrefix
        self.arrivalForecast = arrivalForecast
        self.hasAccessibility = hasAccessibility
        self.lastUpdatedTime = lastUpdatedTime
        self.longitude = longitude
        self.latitude = latitude
    }
    
    enum CodingKeys: String, CodingKey {
        case vehiclePrefix = "p"
        case arrivalForecast = "t"
        case hasAccessibility = "a"
        case lastUpdatedTime = "ta"
        case longitude = "px"
        case latitude = "py"
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var information: String? {
        return "\(vehiclePrefix), previsão de chegada: \(arrivalForecast)"
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
