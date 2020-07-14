//
//  TripViewCell.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 13/07/20.
//

import SwiftUI

struct TripViewCell: View {
    
    @State var tripNumber: String
    @State var destination: String
    
    var body: some View {
        HStack(spacing: 16) {
            HStack {
                Image(systemName: "bus").foregroundColor(.gray)
                Text(tripNumber)
                    .font(.footnote)
                    .fontWeight(.medium)
            }
            .padding(6)
            .border(Color.gray, width: 1)
            .cornerRadius(4)
            
            VStack {
                Text(destination)
                    .font(.footnote)
            }

        }
        .padding(8)

    }
}

struct TripViewCell_Previews: PreviewProvider {
    static var previews: some View {
        TripViewCell(tripNumber: "8000-10", destination: "METRÔ JABAQUARA - CENTRO PARALIMPICO")
    }
}
