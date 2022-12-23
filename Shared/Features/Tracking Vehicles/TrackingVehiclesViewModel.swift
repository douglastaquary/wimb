//
//  TrackingVehiclesViewModel.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 16/07/20.
//
import MapKit
import Combine

class TrackingVehiclesViewModel: ObservableObject {
    
    @Published var trip: Trip
    @Published var vehicles: [VehicleAnnotation] = []
    @Published var stops: [StopBus] = []
    @Published var positions: [CLLocationCoordinate2D] = []
    @Published var loading = false
    @Published var vehiclePositions = [CLLocationCoordinate2D]()
    @Published var didFinished = false
    
    var anyCancellation: AnyCancellable?
    
    public var tripNumber: String {
        return "\(trip.tripId)"
    }

    init(trip: Trip) {
        self.trip = trip
    }
    
    public func fetchVehicles(to numberTrip: String) {
        loading = true
        anyCancellation = APISPTrans.fetchPositions(to: numberTrip, .vehicles)
            .mapError({ (error) -> Error in
                print(error)
                self.loading = false
                return error
            })
            .sink(receiveCompletion: { _ in },
                  receiveValue: {
                self.vehicles = $0.vehicles.map { vehicle -> VehicleAnnotation in
                    let annotation = VehicleAnnotation()
                    annotation.coordinate = vehicle.coordinate
                    annotation.title = vehicle.title
                    annotation.subtitle = vehicle.subtitle
                
                    return annotation
                }
                self.loading = false
                self.startTimer()
                    
                    //self.updateVehiclePositionsIfNeeded(to: $0.vehicles)
                self.positions = self.vehicles.map { $0.coordinate }

            })
    }
    
    public func fetchStops(to numberTrip: String) {
        loading = true
        anyCancellation = APISPTrans.fetchStops(to: numberTrip, .stopsPerTrip)
            .mapError({ (error) -> Error in
                print(error)
                self.loading = false
                return error
            })
            .sink(receiveCompletion: { _ in },
                  receiveValue: { 
                    self.fetchVehicles(to: numberTrip)
                    self.loading = false
                    self.stops = $0
                  })
    }

    @Published var timeRemaining = 20
    private var timer: Timer? = nil

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { tempTimer in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                print("\(self.timeRemaining)")
            } else if self.timeRemaining == 0 {
                self.stopTimer()
                self.timeRemaining = 20
                if !self.loading {
                    self.fetchVehicles(to: self.tripNumber)
                }
            }
        }
    }

    private func stopTimer(){
      timer?.invalidate()
      timer = nil
    }
}


