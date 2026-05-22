//
//  DirectionsTabRootView.swift
//  Shared
//

import SwiftUI

/// Raiz da aba Direções com navegação em pilha.
struct DirectionsTabRootView: View {
    @StateObject private var recentStore = RecentTripsStore()
    @StateObject private var favoritesStore = TripFavoritesStore()

    var body: some View {
        NavigationStack {
            DirectionsHomeView(
                recentStore: recentStore,
                favoritesStore: favoritesStore
            )
        }
    }
}
