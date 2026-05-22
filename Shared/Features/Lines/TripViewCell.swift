//
//  TripViewCell.swift
//  Shared
//

import DesignSystem
import SwiftUI

struct TripViewCell: View {
    let tripNumber: String
    let destination: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            TripTagView(tripNumber: tripNumber)

            Text(destination)
                .font(WIMBTypography.footnote)
                .foregroundColor(WIMBColors.label)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct TripTagView: View {
    let tripNumber: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "bus.fill")
                .font(.caption2)
                .foregroundColor(WIMBColors.busActive)
            Text(tripNumber)
                .font(WIMBTypography.caption)
                .fontWeight(.bold)
                .foregroundColor(WIMBColors.label)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(WIMBColors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(WIMBColors.sheetHandle, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
