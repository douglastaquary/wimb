//
//  ContentView.swift
//  Shared
//
//  Created by Douglas Taquary on 12/07/20.
//

import SwiftUI

struct TripListView: View {
    
    @ObservedObject var viewModel = TripViewModel()
    
    @State private var searchText = ""
    @State private var hideNavBar = true
    @State private var showingCancelButton: Bool = false
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBarView(searchText: $searchText) {
                    self.viewModel.searchTrips(text: searchText)
                }
                if viewModel.loading {
                    ProgressView()
                } else {
                    List {
                        ForEach(viewModel.trips) { trip in
                            NavigationLink(
                                destination: TripDatailView(viewModel: TripDetailViewModel(trip: trip)),
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
        TripListView()
    }
}
