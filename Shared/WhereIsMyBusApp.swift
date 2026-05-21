//
//  WhereIsMyBusApp.swift
//  Shared
//

import SwiftUI
import TransportEngine

@main
struct WhereIsMyBusApp: App {
    @StateObject private var trackingState = WIMBAppEnvironment.makeTrackingState()

    var body: some Scene {
        WindowGroup {
            TripListView()
                .environmentObject(trackingState)
        }
    }
}
