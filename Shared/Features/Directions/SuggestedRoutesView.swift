//
//  SuggestedRoutesView.swift
//  Shared
//

import DesignSystem
import SwiftUI
import TransportEngine
import WIMBCore

/// Lista de rotas sugeridas (Fase 6.5).
struct SuggestedRoutesView: View {
    @EnvironmentObject private var directionsState: DirectionsState
    @ObservedObject var recentStore: RecentTripsStore

    @State private var selectedSuggestion: RouteSuggestion?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let destination = directionsState.destination {
                    Text(destination.displayTitle)
                        .font(WIMBTypography.headline)
                        .foregroundColor(WIMBColors.label)
                }

                if directionsState.suggestions.isEmpty {
                    WIMBEmptyStateView(
                        title: WIMBL10n.plannerEmptyTitle,
                        systemImage: "map",
                        message: WIMBL10n.plannerEmptyMessage
                    )
                    .padding(.top, 24)
                } else {
                    ForEach(directionsState.suggestions) { suggestion in
                        Button {
                            selectedSuggestion = suggestion
                        } label: {
                            WIMBRouteSuggestionCard(content: cardContent(for: suggestion))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .background(WIMBShellColors.screenBackground.ignoresSafeArea())
        .navigationTitle(WIMBL10n.plannerTitle)
        .navigationBarTitleDisplayMode(.inline)
        .background(routeDetailNavigationLink)
    }

    private var routeDetailNavigationLink: some View {
        NavigationLink(
            isActive: Binding(
                get: { selectedSuggestion != nil },
                set: { isActive in
                    if !isActive { selectedSuggestion = nil }
                }
            )
        ) {
            if let suggestion = selectedSuggestion {
                RouteDirectionsView(suggestion: suggestion)
            } else {
                EmptyView()
            }
        } label: {
            EmptyView()
        }
        .hidden()
    }

    private func cardContent(for suggestion: RouteSuggestion) -> RouteSuggestionCardContent {
        let walkTotal = suggestion.walkToBoardMinutes + suggestion.walkFromAlightMinutes

        return RouteSuggestionCardContent(
            lineNumber: suggestion.line.formattedNumber,
            routeDescription: suggestion.line.routeDescription,
            totalMinutesLabel: WIMBL10n.routeTotalMinutes(suggestion.totalMinutes),
            fareLabel: suggestion.formattedFare,
            walkSummaryLabel: WIMBL10n.routeWalkMinutes(walkTotal),
            busSummaryLabel: WIMBL10n.routeBusMinutes(suggestion.waitMinutes + suggestion.busRideMinutes)
        )
    }
}
