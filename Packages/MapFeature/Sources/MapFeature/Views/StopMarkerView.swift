//
//  StopMarkerView.swift
//  MapFeature
//

import SwiftUI
import DesignSystem

struct StopMarkerView: View {
    let name: String

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(WIMBColors.stopMarker)
                .shadow(radius: 2)

            if !name.isEmpty {
                Text(name)
                    .font(.system(size: 8, weight: .medium))
                    .lineLimit(1)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(WIMBColors.surface.opacity(0.9))
                    .cornerRadius(4)
                    .frame(maxWidth: 72)
            }
        }
    }
}

struct StopMarkerView_Previews: PreviewProvider {
    static var previews: some View {
        StopMarkerView(name: "Paulista")
    }
}
