//
//  TripLineDetailPanel.swift
//  Shared
//

import DesignSystem
import SwiftUI
import TransportEngine
import WIMBCore

/// Detalhe da linha com paradas e previsões.
struct TripLineDetailPanel: View {
    @EnvironmentObject private var trackingState: TrackingState
    let line: TransportLine

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                lineHeader

                if trackingState.isLoadingArrivals {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                } else if trackingState.arrivals.isEmpty {
                    WIMBEmptyStateView(
                        title: WIMBL10n.lineStopsEmptyTitle,
                        systemImage: "signpost.right",
                        message: WIMBL10n.lineStopsEmptyMessage
                    )
                } else {
                    WIMBSectionHeader(WIMBL10n.lineStopsTitle)

                    ForEach(stopsWithVehicles) { stop in
                        WIMBListRow {
                            StopArrivalRow(stop: stop)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: 360)
    }

    private var lineHeader: some View {
        WIMBListRow {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TripTagView(tripNumber: line.formattedNumber)
                    Spacer()
                    Label(
                        WIMBL10n.lineBusesOnMap(trackingState.vehicles(for: line.id).count),
                        systemImage: "bus.fill"
                    )
                    .font(WIMBTypography.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)
                }

                Text(line.routeDescription)
                    .font(WIMBTypography.footnote)
                    .foregroundColor(WIMBColors.secondaryLabel)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var stopsWithVehicles: [Stop] {
        trackingState.arrivals.filter(\.hasVehicles)
    }
}

private struct StopArrivalRow: View {
    let stop: Stop

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "figure.wave.circle.fill")
                    .foregroundColor(WIMBColors.stopMarker)
                Text(stop.displayTitle)
                    .font(WIMBTypography.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(WIMBColors.label)
                Spacer()
            }

            if let vehicles = stop.vehicles {
                ForEach(vehicles) { vehicle in
                    VehicleArrivalRow(vehicle: vehicle)
                }
            }
        }
    }
}

private struct VehicleArrivalRow: View {
    let vehicle: WIMBCore.Vehicle

    var body: some View {
        HStack(spacing: 12) {
            TripTagView(tripNumber: vehicle.prefix)

            if vehicle.accessible {
                Image(systemName: "figure.roll")
                    .font(.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)
                    .accessibilityLabel(WIMBL10n.vehicleAccessible)
            }

            Spacer()

            if let forecast = vehicle.arrivalForecast, !forecast.isEmpty {
                Label(forecast, systemImage: "clock")
                    .font(WIMBTypography.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)
            }
        }
    }
}
