//
//  TripListView.swift
//  Shared
//

import DesignSystem
import MapFeature
import SwiftUI
import TransportEngine
import WIMBCore

private extension MapDisplayStrings {
    static var localized: MapDisplayStrings {
        MapDisplayStrings(
            idleStatus: WIMBL10n.mapIdle,
            trackingStatus: WIMBL10n.mapTrackingStatus,
            refreshAccessibilityLabel: WIMBL10n.mapRefresh
        )
    }
}

struct TripListView: View {
    @EnvironmentObject private var trackingState: TrackingState

    var body: some View {
        TransportHomeView(trackingState: trackingState, mapStrings: .localized) {
            TripHomePanel()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TripListView()
            .environmentObject(WIMBAppEnvironment.makeTrackingState())
    }
}
