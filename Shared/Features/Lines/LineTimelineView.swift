//
//  LineTimelineView.swift
//  Shared
//

import DesignSystem
import SwiftUI
import TransportEngine
import WIMBCore

/// Timeline vertical de paradas da linha (Fase 6.2).
struct LineTimelineView: View {
    @EnvironmentObject private var trackingState: TrackingState
    let stops: [Stop]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(stops.enumerated()), id: \.element.id) { index, stop in
                timelineRow(stop: stop, isLast: index == stops.count - 1)
            }
        }
    }

    private func timelineRow(stop: Stop, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(stop.hasVehicles ? WIMBShellColors.etaLive : WIMBColors.sheetHandle)
                    .frame(width: 12, height: 12)

                if !isLast {
                    Rectangle()
                        .fill(WIMBColors.sheetHandle)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 12)

            VStack(alignment: .leading, spacing: 6) {
                Text(stop.displayTitle)
                    .font(WIMBTypography.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(WIMBColors.label)
                    .fixedSize(horizontal: false, vertical: true)

                if let vehicles = stop.vehicles, !vehicles.isEmpty {
                    ForEach(vehicles) { vehicle in
                        HStack(spacing: 8) {
                            TripTagView(tripNumber: vehicle.prefix)
                            Spacer()
                            Text(forecast(for: vehicle, at: stop))
                                .font(WIMBTypography.caption)
                                .foregroundColor(WIMBShellColors.etaLive)
                        }
                    }
                } else {
                    Text(WIMBL10n.lineTimelineNoForecast)
                        .font(WIMBTypography.caption)
                        .foregroundColor(WIMBColors.secondaryLabel)
                }
            }
            .padding(.bottom, isLast ? 0 : 16)
        }
    }

    private func forecast(for vehicle: Vehicle, at stop: Stop) -> String {
        if let forecast = vehicle.arrivalForecast, !forecast.isEmpty {
            return forecast
        }
        let prediction = trackingState.smartPrediction(for: vehicle, at: stop)
        return WIMBL10n.smartETA(minutes: prediction.estimatedMinutes)
    }
}
