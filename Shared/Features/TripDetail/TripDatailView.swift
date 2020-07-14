//
//  TripDatailView.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 14/07/20.
//

import SwiftUI

struct TripDatailView: View {
    
    @ObservedObject var viewModel: TripDetailViewModel
    
    var body: some View {
        
        VStack {
            VStack(spacing: 16) {
                Text(viewModel.trip.secondaryTerminal)
                Text(viewModel.trip.firstPartOfTheSign + "-\(viewModel.trip.secondPartOfTheSign)")
                
            }
            
            List {
                ForEach(viewModel.vehicles) { vehicle in
                    Text(vehicle.vehiclePrefix)
                }
            }
            
        }
        .onAppear {
            self.viewModel.fetchDetail(to: viewModel.trip.tripId)
        }
    }
}

struct TripDatailView_Previews: PreviewProvider {
    static var previews: some View {
        TripDatailView(viewModel: TripDetailViewModel(trip: Trip.tripMock()))
    }
}
