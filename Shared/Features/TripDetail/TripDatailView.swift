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
            TripDetailHeaderView(
                numberTrip: "\(viewModel.trip.tripId)",
                mainTerminal: viewModel.trip.mainTerminal,
                secondaryTerminal: viewModel.trip.secondaryTerminal,
                tagDescription: "acessível"
            )
            if viewModel.isLoading {
                ProgressView()
                Spacer()
            } else {
                
                
//                for stop in viewModel.stops {
//                    VStack(alignment: .center) {
//                      HStack {
//                          Text(stop.descript).frame(width: 100)
//                        //Text("Header 2").frame(maxWidth: .infinity)
//                      }
//                      List {
//                        ForEach(0..<data.count) { num in
//                          HStack {
//                            Text("Row 1-\(num)").frame(width: 100)
//                            Text("Row 2-\(num)").frame(maxWidth: .infinity)
//                          }
//                        }
//                      }
//                    }
//                }
//                
                
                List(viewModel.stops) { stop in
                    StopViewCell(stopName: stop.descript, vehicles: stop.vehicles ?? [])
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


struct TripDetailHeaderView: View {
    
    @State var numberTrip: String
    @State var mainTerminal: String
    @State var secondaryTerminal: String
    @State var tagDescription: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            //TagView(color: .blue, text: numberTrip)
            HStack {
                Image(systemName: "bus").foregroundColor(.blue)
                TagView(color: .blue, text: numberTrip)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            Text("\(mainTerminal) - \(secondaryTerminal)")
            
        }
        .padding(.leading, 16)
    }
    
}


struct TripDetailHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailHeaderView(numberTrip: "8000-10", mainTerminal: "Terminal João Dias", secondaryTerminal: "Aclimação", tagDescription: "acessível")
    }
}


struct TagView: View {
    
    var color: Color
    var text: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(text)
                    .foregroundColor(.white)
                    .font(.body)
                    .fontWeight(.bold)
                    .padding([.top, .bottom], 2)
                    .padding([.leading, .trailing], 4)
                
            }
            .background(color)
            .cornerRadius(4)
        }
    }
    
}


struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(color: .orange, text: "8000-10")
    }
}
