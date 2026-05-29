//
//  LineRouteView.swift
//  Shared
//

import DesignSystem
import MapFeature
import SwiftUI
import TransportEngine
import WIMBCore

/// Detalhe da linha: mapa, header e timeline de paradas (Fase 6.2).
struct LineRouteView: View {
    @EnvironmentObject private var trackingState: TrackingState
    @ObservedObject var recentStore: LinesRecentStore
    @Environment(\.dismiss) private var dismiss

    @State private var displayedLine: TransportLine
    @State private var isSwitchingDirection = false

    init(line: TransportLine, recentStore: LinesRecentStore) {
        self.recentStore = recentStore
        _displayedLine = State(initialValue: line)
    }

    private var lineVehicles: [Vehicle] {
        trackingState.vehicles(for: displayedLine.id)
    }

    var body: some View {
        VStack(spacing: 0) {
            routeHeader

            TransportMapView(
                trackingState: trackingState,
                bottomInsetPoints: 0
            )
            .frame(height: 240)
            .clipped()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    directionSection

                    if trackingState.isLoadingArrivals {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    } else if !trackingState.arrivals.isEmpty {
                        WIMBSectionHeader(WIMBL10n.lineTimelineTitle)
                        LineTimelineView(stops: trackingState.arrivals)
                    } else if !lineVehicles.isEmpty {
                        activeVehiclesSection
                    } else {
                        WIMBEmptyStateView(
                            title: WIMBL10n.lineStopsEmptyTitle,
                            systemImage: "signpost.right",
                            message: WIMBL10n.lineStopsEmptyMessage
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(WIMBShellColors.screenBackground)

            liveTrackingButton
        }
        .background(WIMBShellColors.screenBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task(id: displayedLine.id) {
            if trackingState.trackedLines.contains(where: { $0.id == displayedLine.id }) {
                await trackingState.selectLine(displayedLine)
            } else {
                await trackingState.trackLine(displayedLine)
            }
            recentStore.record(displayedLine)
        }
        .onChange(of: lineVehicles.count) { count in
            guard count > 0,
                  trackingState.arrivals.isEmpty,
                  !trackingState.isLoadingArrivals else { return }
            Task { await trackingState.loadArrivals(for: displayedLine.id) }
        }
    }

    private var activeVehiclesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            WIMBSectionHeader(WIMBL10n.lineActiveVehiclesSection)

            ForEach(lineVehicles) { vehicle in
                HStack(spacing: 10) {
                    TripTagView(tripNumber: vehicle.prefix)

                    if vehicle.accessible {
                        Image(systemName: "figure.roll")
                            .font(.caption)
                            .foregroundColor(WIMBShellColors.tabActive)
                            .accessibilityLabel(WIMBL10n.vehicleAccessible)
                    }

                    Spacer()

                    Text(vehicle.lastUpdateTime)
                        .font(WIMBTypography.caption)
                        .foregroundColor(WIMBShellColors.etaLive)
                }
                .padding(12)
                .background(WIMBColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            Text(WIMBL10n.lineActiveVehiclesHint)
                .font(WIMBTypography.caption)
                .foregroundColor(WIMBColors.secondaryLabel)
        }
    }

    private var routeHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(displayedLine.formattedNumber)
                    .font(WIMBTypography.headline)
                    .foregroundColor(.white)
                Text(displayedLine.routeDescription)
                    .font(WIMBTypography.caption)
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
            }

            Spacer()

            Label(
                WIMBL10n.lineBusesOnMap(trackingState.vehicles(for: displayedLine.id).count),
                systemImage: "bus.fill"
            )
            .font(WIMBTypography.caption)
            .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(WIMBShellColors.plannerHeader)
    }

    private var directionSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(WIMBL10n.lineDirectionTitle)
                    .font(WIMBTypography.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)
                Text(directionLabel)
                    .font(WIMBTypography.footnote)
                    .foregroundColor(WIMBColors.label)
            }

            Spacer()

            if !displayedLine.circular {
                Button {
                    Task { await switchDirection() }
                } label: {
                    Label(WIMBL10n.lineSwitchDirection, systemImage: "arrow.left.arrow.right")
                        .font(WIMBTypography.caption)
                        .foregroundColor(WIMBShellColors.tabActive)
                }
                .buttonStyle(.plain)
                .disabled(isSwitchingDirection)
            }
        }
        .padding(12)
        .background(WIMBColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var liveTrackingButton: some View {
        NavigationLink {
            LiveLineTrackingView(line: displayedLine)
        } label: {
            Text(WIMBL10n.liveTrackingButton)
                .font(WIMBTypography.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(WIMBShellColors.orange)
        }
        .buttonStyle(.plain)
    }

    private var directionLabel: String {
        displayedLine.isOutbound ? WIMBL10n.lineDirectionOutbound : WIMBL10n.lineDirectionInbound
    }

    private func switchDirection() async {
        isSwitchingDirection = true
        await trackingState.searchLines(query: displayedLine.firstPartOfSign)

        if let alternate = trackingState.searchResults.first(where: {
            $0.firstPartOfSign == displayedLine.firstPartOfSign
                && $0.secondPartOfSign == displayedLine.secondPartOfSign
                && $0.direction != displayedLine.direction
        }) {
            displayedLine = alternate
            recentStore.record(alternate)
            await trackingState.selectLine(alternate)
        }

        isSwitchingDirection = false
    }
}
