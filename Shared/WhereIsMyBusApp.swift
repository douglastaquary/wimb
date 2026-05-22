//
//  WhereIsMyBusApp.swift
//  Shared
//

import AppShell
import SwiftUI
import TransportEngine

@main
struct WhereIsMyBusApp: App {
    @StateObject private var trackingState = WIMBAppEnvironment.makeTrackingState()
    @StateObject private var stationsState = WIMBAppEnvironment.makeStationsState()
    @StateObject private var directionsState = WIMBAppEnvironment.makeDirectionsState()
    @StateObject private var navigationState = AppNavigationState()

    var body: some Scene {
        WindowGroup {
            MainShellView(
                navigationState: navigationState,
                strings: .localized,
                directionsTab: {
                    DirectionsTabRootView()
                },
                stationsTab: {
                    StationsTabRootView()
                },
                linesTab: {
                    LinesTabRootView()
                }
            )
            .environmentObject(trackingState)
            .environmentObject(stationsState)
            .environmentObject(directionsState)
        }
    }
}
