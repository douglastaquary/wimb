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
                Text(trip.secondaryTerminal)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
