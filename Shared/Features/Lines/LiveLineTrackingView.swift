//
//  LiveLineTrackingView.swift
//  Shared
//

import DesignSystem
import MapFeature
import SwiftUI
import TransportEngine
import WIMBCore

/// Live tracking em tela cheia (Fase 6.3).
struct LiveLineTrackingView: View {
    @EnvironmentObject private var trackingState: TrackingState
    @Environment(\.dismiss) private var dismiss

    let line: TransportLine

    @State private var refocusMap = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TransportMapView(
                trackingState: trackingState,
                routeStyle: .live,
                bottomSheetRatio: 0.34,
                refocusRequest: $refocusMap
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                LiveTrackingHeader(
                    title: line.formattedNumber,
                    subtitle: headerSubtitle,
                    closeAccessibilityLabel: WIMBL10n.liveTrackingClose,
                    routeAccessibilityLabel: WIMBL10n.liveTrackingShowRoute,
                    onClose: { dismiss() },
                    onShowRoute: { refocusMap = true }
                )

                Spacer()

                WIMBLiveTrackingCard(content: cardContent)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await trackingState.selectLine(line)
        }
    }

    private var headerSubtitle: String? {
        if let stop = liveSnapshot?.referenceStop {
            return stop.displayTitle
        }
        return line.routeDescription
    }

    private var liveSnapshot: LiveTrackingSnapshot? {
        LiveTrackingMetrics.snapshot(
            stops: trackingState.arrivals,
            vehicles: trackingState.vehicles(for: line.id),
            userLocation: trackingState.locationManager.currentLocation,
            etaMinutes: { vehicle, stop in
                trackingState.smartPrediction(for: vehicle, at: stop).estimatedMinutes
            }
        )
    }

    private var cardContent: LiveTrackingCardContent {
        let vehicles = trackingState.vehicles(for: line.id)
        let snapshot = liveSnapshot

        let etaLabel: String
        let stopsAwayLabel: String?

        if let snapshot = snapshot, snapshot.referenceStop != nil {
            etaLabel = WIMBL10n.smartETA(minutes: snapshot.etaMinutes)
            stopsAwayLabel = WIMBL10n.liveTrackingStopsAway(snapshot.stopsAway)
        } else if !vehicles.isEmpty {
            etaLabel = WIMBL10n.liveTrackingLiveNow
            stopsAwayLabel = nil
        } else {
            etaLabel = WIMBL10n.lineStopsEmptyTitle
            stopsAwayLabel = nil
        }

        return LiveTrackingCardContent(
            lineNumber: line.formattedNumber,
            destination: line.secondaryTerminal,
            etaLabel: etaLabel,
            stopsAwayLabel: stopsAwayLabel,
            vehiclePrefix: snapshot?.vehicle.prefix ?? vehicles.first?.prefix,
            busesOnMapLabel: WIMBL10n.lineBusesOnMap(vehicles.count),
            lastUpdate: trackingState.lastUpdate,
            pollingInterval: trackingState.pollingInterval,
            refreshCountdownLabel: WIMBL10n.liveTrackingRefreshIn
        )
    }
}
