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
                  receiveValue: {
                    print("\n✅ App autenticado na API da SPTrans!\n")
                    self.isLoading = false
                    self.vehicles = $0.vehicles
            })
    }
    
}

