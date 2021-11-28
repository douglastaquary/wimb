//
//  VehicleInformationViewCell.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 14/07/20.
//

import SwiftUI

struct VehicleInformationViewCell: View {
    @State var vehicleNumber: String
    @State var arrivalForecast: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 16) {
                TripTagView(tripNumber: vehicleNumber)
                Spacer()
                HStack {
                    Image(systemName: "wave.3.left")
                    Text("Chegada às \(arrivalForecast)")
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct VehicleInformationViewCell_Previews: PreviewProvider {
    static var previews: some View {
        VehicleInformationViewCell(vehicleNumber: "1697", arrivalForecast: "23:30")
    }
}


struct StopViewCell: View {
    @State var stopName: String
    @State var vehicles: [Vehicle]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if stopName.isEmpty {
                    Image(systemName: "figure.wave.circle.fill").foregroundColor(.gray)
                        .padding(.leading, 6)
                } else {
                    Image(systemName: "figure.wave.circle.fill").foregroundColor(.green)
                        .padding(.leading, 6)
                }
                Text(configStopNameIfNeeded())
                    .font(.footnote)
                    .fontWeight(.medium)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 12)
            VStack {
                if !vehicles.isEmpty {
                    ForEach(vehicles) { vehicle in
                        VehicleInformationViewCell(
                            vehicleNumber: vehicle.vehiclePrefix, arrivalForecast: vehicle.arrivalForecast ?? ""
                        )
                    }
                }
            }
        }
        
    }
    
    private func configStopNameIfNeeded() -> String {
        if stopName.isEmpty {
            return "Ponto não informado pela sptrans"
        }
        return stopName
    }
}

struct StopViewCell_Previews: PreviewProvider {
    static var previews: some View {
        StopViewCell(
            stopName: "Ana Cintra",
            vehicles: [
                Vehicle(vehiclePrefix: "9876", arrivalForecast: "17:50", hasAccessibility: true, lastUpdatedTime: "17:00", longitude: 0980099, latitude: 00988667)
            ]
        )
    }
}
