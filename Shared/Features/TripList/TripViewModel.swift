//
//  TripViewModel.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 12/07/20.
//

import Foundation
import Combine

class TripViewModel: ObservableObject {
    
    @Published var searchText = ""
    @Published var trips: [Trip] = []
    @Published var isCheck = false
    @Published var loading = false
    var anyCancellation: AnyCancellable?
    
    init() {
        checkAuth()
    }
    
}

extension TripViewModel {
    
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
                    print("\n✅ App autenticado na API da SPTrans!\n")
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
    
}
