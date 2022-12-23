//
//  ContentView.swift
//  Shared
//
//  Created by Douglas Taquary on 12/07/20.
//

import SwiftUI

struct SearchTripView: View {
    
    @ObservedObject var viewModel = SearchTripViewModel()
    
    @State private var searchText = ""
    @State private var hideNavBar = true
    @State private var showingCancelButton: Bool = false
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBarView(searchText: self.$searchText) {
                    self.viewModel.searchTrips(text: searchText)
                } onClear: {
                    self.viewModel.clearTrips()
                }

                if viewModel.loading {
                    ProgressView()
                    Spacer()
                } else {
                    if viewModel.trips.isEmpty {
                        RecentSearchListView(clearAction: {})
                    }
                    List {
                        ForEach(viewModel.trips) { trip in
                            NavigationLink(
                                destination: TrackingVehiclesView(viewModel: TrackingVehiclesViewModel(trip: trip)
                                ),
                                label: {
                                    TripViewCell(
                                        tripNumber: "\(trip.firstPartOfTheSign)-\(trip.secondPartOfTheSign)", destination: "\(trip.mainTerminal) - \(trip.secondaryTerminal)"
                                    )
                                })
                            
                        }
                    }
                    .listStyle(GroupedListStyle())
                    .navigationBarTitle(Text("Buscar"))
                }
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchTripView()
    }
}
