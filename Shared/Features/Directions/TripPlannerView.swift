//
//  TripPlannerView.swift
//  Shared
//

import DesignSystem
import SwiftUI
import TransportEngine
import WIMBCore

/// Planejador origem/destino com horário de saída (Fase 6.5).
struct TripPlannerView: View {
    @EnvironmentObject private var directionsState: DirectionsState
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var recentStore: RecentTripsStore
    @ObservedObject var favoritesStore: TripFavoritesStore

    let initialDestination: TripPlace?

    @State private var showSuggestions = false
    @State private var destinationQuery = ""

    init(
        recentStore: RecentTripsStore,
        favoritesStore: TripFavoritesStore,
        initialDestination: TripPlace? = nil
    ) {
        self.recentStore = recentStore
        self.favoritesStore = favoritesStore
        self.initialDestination = initialDestination
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                endpointCard
                departureSection
                planButton

                if let error = directionsState.error, directionsState.suggestions.isEmpty {
                    Text(error.userMessage)
                        .font(WIMBTypography.caption)
                        .foregroundColor(WIMBColors.secondaryLabel)
                }

                Text(WIMBL10n.plannerDisclaimer)
                    .font(WIMBTypography.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)
            }
            .padding(16)
        }
        .background(WIMBShellColors.screenBackground.ignoresSafeArea())
        .navigationTitle(WIMBL10n.plannerTitle)
        .navigationBarTitleDisplayMode(.inline)
        .background(suggestionsNavigationLink)
        .task {
            if directionsState.origin == nil {
                await directionsState.resolveOriginFromLocation(defaultName: WIMBL10n.plannerCurrentLocation)
            }
            if let initialDestination {
                directionsState.destination = initialDestination
                destinationQuery = initialDestination.displayTitle
            } else if let destination = directionsState.destination {
                destinationQuery = destination.displayTitle
            }
        }
    }

    private var endpointCard: some View {
        VStack(spacing: 0) {
            endpointRow(
                icon: "location.circle.fill",
                iconColor: WIMBShellColors.tabActive,
                title: directionsState.origin?.displayTitle ?? WIMBL10n.plannerCurrentLocation,
                subtitle: WIMBL10n.plannerOriginLabel
            )

            Divider()
                .padding(.leading, 44)

            HStack(spacing: 0) {
                endpointSearchRow

                Button {
                    directionsState.swapEndpoints()
                    if let destination = directionsState.destination {
                        destinationQuery = destination.displayTitle
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.body.weight(.semibold))
                        .foregroundColor(WIMBShellColors.orange)
                        .frame(width: 44, height: 52)
                }
                .buttonStyle(.plain)
            }
        }
        .background(WIMBColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    private var endpointSearchRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(WIMBShellColors.orange)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(WIMBL10n.plannerDestinationLabel)
                    .font(WIMBTypography.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)

                TextField(WIMBL10n.shellDirectionsSearchPlaceholder, text: $destinationQuery)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await searchAndSelectDestination() }
                    }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func endpointRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(subtitle)
                    .font(WIMBTypography.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)
                Text(title)
                    .font(WIMBTypography.footnote)
                    .foregroundColor(WIMBColors.label)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var departureSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            WIMBSectionHeader(WIMBL10n.plannerDepartureSection)

            HStack(spacing: 8) {
                departureChip(minutes: 0, label: WIMBL10n.plannerDepartureNow)
                departureChip(minutes: -15, label: WIMBL10n.plannerDepartureEarlier)
                departureChip(minutes: 15, label: WIMBL10n.plannerDepartureLater)
            }
        }
    }

    private func departureChip(minutes: Int, label: String) -> some View {
        let isSelected = directionsState.departureOffsetMinutes == minutes

        return Button {
            directionsState.departureOffsetMinutes = minutes
        } label: {
            Text(label)
                .font(WIMBTypography.caption)
                .foregroundColor(isSelected ? .white : WIMBColors.label)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? WIMBShellColors.tabActive : WIMBColors.surfaceSecondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var planButton: some View {
        Button {
            Task {
                await searchAndSelectDestination()
                await directionsState.planRoutes()
                if !directionsState.suggestions.isEmpty {
                    showSuggestions = true
                }
            }
        } label: {
            Group {
                if directionsState.isPlanning {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(WIMBL10n.plannerShowRoutes)
                        .font(WIMBTypography.headline)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(WIMBShellColors.orange)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(directionsState.isPlanning)
    }

    private var suggestionsNavigationLink: some View {
        NavigationLink(
            isActive: $showSuggestions
        ) {
            SuggestedRoutesView(recentStore: recentStore)
        } label: {
            EmptyView()
        }
        .hidden()
    }

    private func searchAndSelectDestination() async {
        let trimmed = destinationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let existing = directionsState.destination, existing.displayTitle == trimmed {
            return
        }

        await directionsState.searchPlaces(query: trimmed)
        if let first = directionsState.placeSearchResults.first {
            directionsState.destination = first
            destinationQuery = first.displayTitle
            recentStore.record(first)
        }
    }
}
