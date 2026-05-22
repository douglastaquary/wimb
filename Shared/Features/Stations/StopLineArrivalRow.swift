//
//  StopLineArrivalRow.swift
//  Shared
//

import DesignSystem
import SwiftUI
import WIMBCore

/// Linha com previsão na parada (Fase 6.4).
struct StopLineArrivalRow: View {
    let lineForecast: StopLineForecast
    let etaLabel: String

    var body: some View {
        WIMBListRow {
            HStack(spacing: 12) {
                TripTagView(tripNumber: lineNumberLabel)

                VStack(alignment: .leading, spacing: 4) {
                    Text(lineForecast.line.routeDescription)
                        .font(WIMBTypography.caption)
                        .foregroundColor(WIMBColors.label)
                        .lineLimit(2)

                    if lineForecast.vehicles.count > 1 {
                        Text(WIMBL10n.stationsMultipleBuses(lineForecast.vehicles.count))
                            .font(WIMBTypography.caption)
                            .foregroundColor(WIMBColors.secondaryLabel)
                    }
                }

                Spacer()

                Text(etaLabel)
                    .font(WIMBTypography.headline)
                    .foregroundColor(WIMBShellColors.etaLive)
            }
        }
    }

    private var lineNumberLabel: String {
        if lineForecast.line.secondPartOfSign == 0 {
            return lineForecast.line.firstPartOfSign
        }
        return lineForecast.line.formattedNumber
    }
}
