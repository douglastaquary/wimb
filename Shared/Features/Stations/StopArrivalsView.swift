//
//  StopArrivalsView.swift
//  Shared
//

import DesignSystem
import SwiftUI
import TransportEngine
import WIMBCore

/// Detalhe da parada com linhas e previsões (Fase 6.4).
struct StopArrivalsView: View {
    @EnvironmentObject private var stationsState: StationsState
    @EnvironmentObject private var trackingState: TrackingState
    @Environment(\.dismiss) private var dismiss

    let stop: Stop

    @State private var liveLine: TransportLine?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                if stationsState.isLoadingDetail {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                } else if let detail = stationsState.stopDetail {
                    if detail.lines.isEmpty {
                        WIMBEmptyStateView(
                            title: WIMBL10n.stationsNoArrivalsTitle,
                            systemImage: "clock",
                            message: WIMBL10n.stationsNoArrivalsMessage
                        )
                    } else {
                        WIMBSectionHeader(WIMBL10n.stationsArrivalsSection)

                        ForEach(detail.lines) { lineForecast in
                            Button {
                                Task { await openLiveTracking(for: lineForecast.line) }
                            } label: {
                                StopLineArrivalRow(
                                    lineForecast: lineForecast,
                                    etaLabel: etaLabel(for: lineForecast)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else if let error = stationsState.error {
                    WIMBEmptyStateView(
                        title: WIMBL10n.searchErrorTitle,
                        systemImage: "exclamationmark.triangle",
                        message: error.userMessage
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(WIMBShellColors.screenBackground.ignoresSafeArea())
        .navigationTitle(stop.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .background(hiddenLiveNavigationLink)
        .task(id: stop.id) {
            await stationsState.loadStopDetail(stopId: stop.id)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(stop.displayTitle, systemImage: "mappin.circle.fill")
                .font(WIMBTypography.headline)
                .foregroundColor(WIMBColors.label)

            if let hour = stationsState.stopDetail?.queryHour {
                Text(WIMBL10n.stationsUpdatedAt(hour))
                    .font(WIMBTypography.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(WIMBColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var hiddenLiveNavigationLink: some View {
        NavigationLink(
            isActive: Binding(
                get: { liveLine != nil },
                set: { isActive in
                    if !isActive { liveLine = nil }
                }
            )
        ) {
            if let line = liveLine {
                LiveLineTrackingView(line: line)
            } else {
                EmptyView()
            }
        } label: {
            EmptyView()
        }
        .hidden()
    }

    private func etaLabel(for lineForecast: StopLineForecast) -> String {
        guard let vehicle = lineForecast.vehicles.first else {
            return WIMBL10n.lineTimelineNoForecast
        }

        if let forecast = vehicle.arrivalForecast, !forecast.isEmpty {
            return forecast
        }

        let prediction = trackingState.smartPrediction(for: vehicle, at: stop)
        return WIMBL10n.smartETA(minutes: prediction.estimatedMinutes)
    }

    private func openLiveTracking(for line: TransportLine) async {
        if trackingState.trackedLines.contains(where: { $0.id == line.id }) {
            await trackingState.selectLine(line)
        } else {
            await trackingState.trackLine(line)
        }
        liveLine = line
    }
}
