//
//  TrackingVehiclesView.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 16/07/20.
//

import SwiftUI
import MapKit

struct TrackingVehiclesView: View {
    @ObservedObject var viewModel: TrackingVehiclesViewModel

    var body: some View {
        ZStack {
            MapView(
                showMapAlert: .constant(false),
                vehicles: $viewModel.vehicles,
                stops: $viewModel.stops
            )
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            viewModel.fetchStops(to: "\(viewModel.tripNumber)")
        }
        .navigationBarTitle("Ônibus on line", displayMode: .inline)
        .navigationBarItems(
            trailing: Text("\(viewModel.timeRemaining)")
        )
    }

}

struct TrackingVehiclesView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingVehiclesView(viewModel: TrackingVehiclesViewModel(trip: Trip.tripMock()))
    }
}
