//
//  MetroAlternativesSection.swift
//  Shared
//

import DesignSystem
import SwiftUI
import TransportEngine
import WIMBCore

/// Sugestões de metrô próximo ao usuário.
struct MetroAlternativesSection: View {
    let stops: [NearbyMetroStop]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            WIMBSectionHeader(WIMBL10n.metroSection)

            Text(WIMBL10n.metroHint)
                .font(WIMBTypography.caption)
                .foregroundColor(WIMBColors.secondaryLabel)

            ForEach(stops) { stop in
                WIMBListRow {
                    MetroStopRow(stop: stop)
                }
            }
        }
    }
}

private struct MetroStopRow: View {
    let stop: NearbyMetroStop

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "tram.fill")
                .font(.title3)
                .foregroundColor(WIMBColors.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text(stop.station.name)
                    .font(WIMBTypography.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(WIMBColors.label)

                Text(stop.station.lines.joined(separator: " · "))
                    .font(WIMBTypography.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)
                    .lineLimit(1)
            }

            Spacer()

            Text(WIMBL10n.metroWalkingMinutes(stop.walkingMinutes))
                .font(WIMBTypography.caption)
                .foregroundColor(WIMBColors.secondaryLabel)
        }
    }
}
