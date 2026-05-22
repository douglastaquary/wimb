//
//  DirectionsHomeView.swift
//  Shared
//

import DesignSystem
import SwiftUI
import TransportEngine
import WIMBCore

/// Home da aba Direções: hero, busca, recentes e favoritos (Fase 6.5).
struct DirectionsHomeView: View {
    @EnvironmentObject private var directionsState: DirectionsState
    @EnvironmentObject private var trackingState: TrackingState
    @ObservedObject var recentStore: RecentTripsStore
    @ObservedObject var favoritesStore: TripFavoritesStore

    @State private var searchText = ""
    @State private var showPlanner = false
    @State private var pendingDestination: TripPlace?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroSection
                searchField

                if directionsState.isSearchingPlaces {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if !directionsState.placeSearchResults.isEmpty {
                    searchResultsSection
                }

                favoritesSection

                if !recentStore.places.isEmpty {
                    recentSection
                }

                if !trackingState.nearbyMetro.isEmpty {
                    MetroAlternativesSection(stops: trackingState.nearbyMetro)
                }

                disclaimer
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(WIMBShellColors.screenBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .background(hiddenNavigationLink)
        .task {
            await directionsState.resolveOriginFromLocation(defaultName: WIMBL10n.plannerCurrentLocation)
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(WIMBL10n.shellRegionTitle)
                .font(WIMBTypography.caption)
                .foregroundColor(.white.opacity(0.85))

            Text(WIMBL10n.directionsPrompt)
                .font(WIMBTypography.title)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [WIMBShellColors.heroGradientTop, WIMBShellColors.heroGradientBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var searchField: some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(WIMBColors.secondaryLabel)
                TextField(WIMBL10n.shellDirectionsSearchPlaceholder, text: $searchText)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await directionsState.searchPlaces(query: searchText) }
                    }
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 48)

            Button {
                Task { await directionsState.searchPlaces(query: searchText) }
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
        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
    }

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            WIMBSectionHeader(WIMBL10n.searchResults)

            ForEach(directionsState.placeSearchResults.prefix(6)) { place in
                placeListRow(place)
            }
        }
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            WIMBSectionHeader(WIMBL10n.directionsFavoritesSection)

            HStack(spacing: 12) {
                favoriteChip(kind: .home, title: WIMBL10n.directionsFavoriteHome, systemImage: "house.fill")
                favoriteChip(kind: .work, title: WIMBL10n.directionsFavoriteWork, systemImage: "briefcase.fill")
            }

            if favoritesStore.home == nil, favoritesStore.work == nil {
                Text(WIMBL10n.directionsFavoritesHint)
                    .font(WIMBTypography.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)
            }
        }
    }

    private func favoriteChip(
        kind: TripFavoriteKind,
        title: String,
        systemImage: String
    ) -> some View {
        let savedPlace = favoritesStore.place(for: kind)

        return HStack(spacing: 0) {
            Button {
                if let place = savedPlace {
                    openPlanner(with: place)
                }
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: systemImage)
                        Text(title)
                            .lineLimit(1)
                    }
                    if let savedPlace {
                        Text(savedPlace.displayTitle)
                            .font(WIMBTypography.caption)
                            .foregroundColor(WIMBColors.secondaryLabel)
                            .lineLimit(1)
                    }
                }
                .font(WIMBTypography.footnote)
                .foregroundColor(WIMBColors.label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 12)
                .padding(.horizontal, 10)
            }
            .buttonStyle(.plain)
            .disabled(savedPlace == nil)

            if let savedPlace {
                favoriteMenu(for: savedPlace, kind: kind)
                    .padding(.trailing, 6)
            }
        }
        .background(WIMBColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .opacity(savedPlace == nil ? 0.55 : 1)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                WIMBSectionHeader(WIMBL10n.directionsRecentSection)

                Spacer(minLength: 8)

                Button {
                    recentStore.clearAll()
                } label: {
                    Text(WIMBL10n.directionsClearRecent)
                        .font(WIMBTypography.caption)
                        .foregroundColor(WIMBShellColors.tabActive)
                }
                .buttonStyle(.plain)
            }

            ForEach(recentStore.places) { place in
                placeListRow(place)
            }
        }
    }

    private func placeListRow(_ place: TripPlace) -> some View {
        WIMBListRow {
            HStack(spacing: 8) {
                Button {
                    openPlanner(with: place)
                } label: {
                    placeRowContent(place)
                }
                .buttonStyle(.plain)

                favoriteMenu(for: place)
            }
        }
    }

    private func placeRowContent(_ place: TripPlace) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "mappin.and.ellipse")
                .foregroundColor(WIMBShellColors.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(place.displayTitle)
                    .font(WIMBTypography.footnote)
                    .foregroundColor(WIMBColors.label)
                    .multilineTextAlignment(.leading)
                if let subtitle = place.subtitle {
                    Text(subtitle)
                        .font(WIMBTypography.caption)
                        .foregroundColor(WIMBColors.secondaryLabel)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func favoriteMenu(for place: TripPlace, kind: TripFavoriteKind? = nil) -> some View {
        Menu {
            Button {
                favoritesStore.set(place, for: .home)
            } label: {
                Label(WIMBL10n.directionsFavoriteSaveHome, systemImage: "house.fill")
            }

            Button {
                favoritesStore.set(place, for: .work)
            } label: {
                Label(WIMBL10n.directionsFavoriteSaveWork, systemImage: "briefcase.fill")
            }

            if kind != nil {
                Divider()

                Button(role: .destructive) {
                    if let kind {
                        favoritesStore.set(nil, for: kind)
                    }
                } label: {
                    Label(WIMBL10n.directionsFavoriteClear, systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title3)
                .foregroundColor(WIMBColors.secondaryLabel)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(WIMBL10n.directionsPlaceActions)
    }

    private var disclaimer: some View {
        Text(WIMBL10n.plannerDisclaimer)
            .font(WIMBTypography.caption)
            .foregroundColor(WIMBColors.secondaryLabel)
            .padding(.top, 4)
    }

    private var hiddenNavigationLink: some View {
        NavigationLink(
            isActive: $showPlanner
        ) {
            TripPlannerView(
                recentStore: recentStore,
                favoritesStore: favoritesStore,
                initialDestination: pendingDestination
            )
        } label: {
            EmptyView()
        }
        .hidden()
    }

    private func openPlanner(with place: TripPlace) {
        directionsState.destination = place
        pendingDestination = place
        recentStore.record(place)
        showPlanner = true
    }
}
