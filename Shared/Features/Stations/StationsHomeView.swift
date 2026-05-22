//
//  StationsHomeView.swift
//  Shared
//

import DesignSystem
import MapFeature
import SwiftUI
import TransportEngine
import WIMBCore

/// Mapa de paradas com busca e botão de paradas próximas (Fase 6.4).
struct StationsHomeView: View {
    @EnvironmentObject private var stationsState: StationsState
    @EnvironmentObject private var trackingState: TrackingState

    @State private var searchText = ""
    @State private var refocusMap = false
    @State private var selectedStop: Stop?

    private var displayStops: [Stop] {
        if !stationsState.searchResults.isEmpty {
            return stationsState.searchResults
        }
        return stationsState.mapStops
    }

    var body: some View {
        ZStack(alignment: .top) {
            StationsMapView(
                stops: displayStops,
                selectedStopId: selectedStop?.id,
                userCoordinate: stationsState.locationManager.currentLocation,
                bottomInset: 180,
                refocusRequest: $refocusMap,
                onSelectStop: { stop in
                    selectedStop = stop
                }
            )

            VStack(spacing: 12) {
                searchField
                Spacer()
                bottomPanel
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .navigationBarHidden(true)
        .background(hiddenNavigationLink)
        .task {
            if stationsState.mapStops.isEmpty {
                await loadNearby()
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(WIMBColors.secondaryLabel)
                TextField(WIMBL10n.stationsSearchPlaceholder, text: $searchText)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await stationsState.searchStops(query: searchText) }
                    }
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 48)

            Button {
                Task { await stationsState.searchStops(query: searchText) }
            } label: {
                ZStack {
                    WIMBShellColors.orange
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(width: 52, height: 48)
            }
            .buttonStyle(.plain)
        }
        .background(WIMBColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
    }

    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                Task { await loadNearby() }
            } label: {
                Text(WIMBL10n.stationsNearbyButton)
                    .font(WIMBTypography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(WIMBShellColors.tabActive)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(stationsState.isLoading)

            if stationsState.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if let error = stationsState.error, displayStops.isEmpty {
                Text(error.userMessage)
                    .font(WIMBTypography.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)
            } else if displayStops.isEmpty {
                Text(WIMBL10n.stationsEmptyMessage)
                    .font(WIMBTypography.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)
            } else {
                WIMBSectionHeader(WIMBL10n.stationsResultsSection)

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(displayStops.prefix(8)) { stop in
                            Button {
                                selectedStop = stop
                            } label: {
                                WIMBListRow {
                                    HStack(spacing: 10) {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(WIMBShellColors.tabActive)
                                        Text(stop.displayTitle)
                                            .font(WIMBTypography.footnote)
                                            .foregroundColor(WIMBColors.label)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(WIMBColors.secondaryLabel)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 180)
            }
        }
        .padding(14)
        .background(WIMBColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 8, y: -2)
    }

    private var hiddenNavigationLink: some View {
        NavigationLink(
            isActive: Binding(
                get: { selectedStop != nil },
                set: { isActive in
                    if !isActive { selectedStop = nil }
                }
            )
        ) {
            if let stop = selectedStop {
                StopArrivalsView(stop: stop)
            } else {
                EmptyView()
            }
        } label: {
            EmptyView()
        }
        .hidden()
    }

    private func loadNearby() async {
        let fallback = trackingState.arrivals
        await stationsState.loadNearbyStops(fallbackStops: fallback)
        refocusMap = true
    }
}
