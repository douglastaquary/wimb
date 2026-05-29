//
//  VehicleMarkerView.swift
//  MapFeature
//

import SwiftUI
import DesignSystem

#if canImport(UIKit)
import UIKit
#endif

struct VehicleMarkerView: View {
    let prefix: String
    let heading: Double

    var body: some View {
        ZStack {
            busMarkerImage
                .rotationEffect(.radians(heading))
                .shadow(color: .black.opacity(0.25), radius: 3, y: 1)

            Text(prefix)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
                .offset(y: -20)
        }
        .accessibilityLabel("Ônibus \(prefix)")
    }

    @ViewBuilder
    private var busMarkerImage: some View {
        #if canImport(UIKit)
        if let uiImage = UIImage(named: "bus_top", in: .main, compatibleWith: nil) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        } else {
            fallbackBusIcon
        }
        #else
        fallbackBusIcon
        #endif
    }

    private var fallbackBusIcon: some View {
        Image(systemName: "bus.fill")
            .font(.system(size: 22))
            .foregroundColor(WIMBColors.busActive)
    }
}

struct VehicleMarkerView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleMarkerView(prefix: "74512", heading: 0)
    }
}
