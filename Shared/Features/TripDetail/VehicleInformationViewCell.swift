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
                HStack {
                    Image(systemName: "bus").foregroundColor(.gray)
                    Text(vehicleNumber)
                        .font(.footnote)
                        .fontWeight(.medium)
                }
                .padding(6)
                .border(Color.gray, width: 1)
                .cornerRadius(4)

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
                Image(systemName: "figure.wave.circle.fill").foregroundColor(.gray)
                Text(stopName)
                    .font(.footnote)
                    .fontWeight(.medium)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            VStack {
                if vehicles.isEmpty {
                    Text("Nenhum veículo encontrado no momento.").font(.footnote)
                    
                } else {
                    ForEach(vehicles) { vehicle in
                        VehicleInformationViewCell(
                            vehicleNumber: vehicle.vehiclePrefix, arrivalForecast: vehicle.arrivalForecast
                        )
                    }
                }
                
            }
        }
    }
}

struct StopViewCell_Previews: PreviewProvider {
    static var previews: some View {
        StopViewCell(stopName: "Ana Cintra", vehicles: [Vehicle(id: UUID(), vehiclePrefix: "9876", arrivalForecast: "17:50", hasAccessibility: true, lastUpdatedTime: "17:00", longitude: 0980099, latitude: 00988667)])
    }
}
