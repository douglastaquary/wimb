//
//  RecentSearchListView.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 15/07/20.
//

import SwiftUI

struct RecentSearchListView: View {
    
    var recentTrips: [Trip] = [
        Trip.tripMock(),
        Trip.tripMock()
    ]
    
    var clearAction: (() -> Void) = { print("Clear action touched") }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Buscas recentes")
                    .padding(.leading, 16)
                
                Spacer()
                Button(action: clearAction) {
                    Text("Limpar")
                        .foregroundColor(.primary)
                        .padding(.all, 10)
                        
                }
                .padding(.trailing, 16)
            }
            
            ForEach(recentTrips) { trip in
                Text("\(trip.firstPartOfTheSign)-\(trip.secondPartOfTheSign) • \(trip.mainTerminal) - \(trip.secondaryTerminal)")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.all, 8)
            }
            .padding(.leading, 8)
        }
    }
}

struct RecentSearchListView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSearchListView(recentTrips: [Trip.tripMock(),
                                           Trip.tripMock()],
                             clearAction: {})
    }
}


struct RecentSearch: Codable, Identifiable {
    var id = UUID()
    let searchText:  String

}
