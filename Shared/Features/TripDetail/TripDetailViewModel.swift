//
//  TripDetailViewModel.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 14/07/20.
//

import Foundation
import Combine

class TripDetailViewModel: ObservableObject {
    
    @Published var trip: Trip
    @Published var vehicles: [Vehicle] = []
    @Published var stops: [StopBus] = []
    @Published var isLoading = false
    
    var anyCancellation: AnyCancellable?
    
    init(trip: Trip) {
        self.trip = trip
    }
}

extension TripDetailViewModel {
    
    func fetchDetail(to numberTrip: Int) {
        isLoading = true
        anyCancellation = APISPTrans.performTripArrives(to: numberTrip, .arrivals)
            .mapError({ (error) -> Error in
                print(error)
                self.isLoading = false
                return error
            })
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in
                    guard let `self` = self else { return }
                    self.stops = $0.stops ?? []
                    self.vehicles = self.mergeVehicles(to: self.stops)
                    self.isLoading = false
            })
    }
    
    func mergeVehicles(to stops: [StopBus]) -> [Vehicle] {
        guard !stops.isEmpty else {
            return []
        }
        for stop in stops {
            self.vehicles.append(contentsOf: stop.vehicles ?? [])
        }

        return self.vehicles
    }
    
}

