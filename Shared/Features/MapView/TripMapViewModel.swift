//
//  TripMapViewModel.swift
//  iOS
//
//  Created by Douglas Taquary on 28/11/21.
//

import SwiftUI
import MapKit
import Combine

class TripMapViewModel: ObservableObject {
    
    @Published var stops: [StopBus]
    @Published var tripCode: String
    @Published var vehicleAnnotations: [AnyMapAnnotationItem] = []
    @Published var stopAnnotations: [AnyMapAnnotationItem] = []
    @Published var allAnnotations: [AnyMapAnnotationItem] = []
    @Published var vehicles: [Vehicle] = []
    @Published var loading = false
    var anyCancellation: AnyCancellable?
    
    @Published public var region: MKCoordinateRegion = MKCoordinateRegion(center: TripMapViewModel.defaultCoordinate, span: TripMapViewModel.defaultSpan)
    private var userTrackingMode: MapUserTrackingMode = .follow
    
    public let locationManager = CLLocationManager()
    public static let defaultCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -23.660826, longitude: -46.679442)
    public static let defaultSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)

    
    init(stops: [StopBus] = [], tripCode: String = "") {
        self.stops = stops
        self.tripCode = tripCode
        configStopAnnotations()
    }
    
    private func configStopAnnotations() {
        for stop in stops {
            stopAnnotations.append(AnyMapAnnotationItem.init(stop))
        }
        allAnnotations.append(contentsOf: stopAnnotations)
    }
    
    private func configVehicleAnnotations() {
        for vehicle in vehicles {
            vehicleAnnotations.append(AnyMapAnnotationItem.init(vehicle))
        }
    }
    
    
    private func addVehiclesAnnotations() {
        allAnnotations.append(contentsOf: vehicleAnnotations)
    }
}

extension TripMapViewModel {
    
    public func positions() {
        loading = true
        anyCancellation = APISPTrans.positionPerTrips(codigoLinha: tripCode, .positionsPerTrip)
            .mapError({ (error) -> Error in
                print(error)
                self.loading = false
                print("[Info] Map Error: \n\(error)\n")
                return error
            })
            .sink(receiveCompletion: { _ in },
                  receiveValue: {
                    self.loading = false
                    print("[Info] Vehicles: \n\($0)\n")
                    self.vehicles = $0.vehicles ?? []
                    self.configVehicleAnnotations()
                    self.addVehiclesAnnotations()
            })
    }
    
}

