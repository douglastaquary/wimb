//
//  ContentView.swift
//  Shared
//
//  Created by Douglas Taquary on 12/07/20.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel = TripViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.trips) { trip in
                HStack {
                    Image(systemName: "bus")
                    Text("\(trip.firstPartOfTheSign)-\(trip.secondPartOfTheSign)")
                        .font(.footnote)
                        .fontWeight(.medium)
                    VStack {
                        Text("\(trip.mainTerminal) - \(trip.secondaryTerminal)")
                            .font(.callout)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
