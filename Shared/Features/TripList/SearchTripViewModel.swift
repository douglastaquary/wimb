//
//  TripViewModel.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 12/07/20.
//

import Foundation
import Combine

class SearchTripViewModel: ObservableObject {
    
    @Published var searchText = ""
    @Published var trips: [Trip] = []
    @Published var isCheck = false
    @Published var loading = false
    var anyCancellation: AnyCancellable?
    
    init() {
        checkAuth()
    }
    
}

extension SearchTripViewModel {
    
    func checkAuth() {
        loading = true
        anyCancellation = APISPTrans.checkAuth(.auth)
            .mapError({ (error) -> Error in
                print(error)
                self.loading = false
                return error
            })
            .sink(receiveCompletion: { _ in },
                  receiveValue: { _ in
                    print("\n✅ Autentication ok\n")
                    self.loading = false
                    self.isCheck = true
                    //self.searchTrips()
            })
    }
    
    public func searchTrips(text: String) {
        loading = true
        anyCancellation = APISPTrans.fetchTrips(text: text, .trips)
            .mapError({ (error) -> Error in
                print(error)
                self.loading = false
                return error
            })
            .sink(receiveCompletion: { _ in },
                  receiveValue: {
                    self.loading = false
                    self.trips = $0
            })
    }
    
    
    func clearTrips() {
        trips.removeAll()
    }
    
}
