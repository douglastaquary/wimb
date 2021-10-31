//
//  VehicleInformationViewCell.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 14/07/20.
//

import SwiftUI

struct VehicleInformationViewCell: View {
    @State var vehicleNumber: String
    @State var distanceBusTop: String
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
                    Image(systemName: "figure.walk")
                    Text("\(distanceBusTop)")
                }
                HStack {
                    Image(systemName: "wave.3.left")
                    Text("\(arrivalForecast)")
                }
            }
            .frame(maxWidth: .infinity)
            //.padding([.trailing, .bottom, .top], 12)
        }
    }
}

struct VehicleInformationViewCell_Previews: PreviewProvider {
    static var previews: some View {
        VehicleInformationViewCell(vehicleNumber: "1697", distanceBusTop: "150m", arrivalForecast: "23:30")
    }
}
