//
//  LinesHomeView.swift
//  Shared
//

import DesignSystem
import SwiftUI
import TransportEngine
import WIMBCore

enum LinesFilter: String, CaseIterable, Identifiable {
    case all
    case bus

    var id: String { rawValue }
}

/// Home da aba Linhas: busca, filtros e recentes (Fase 6.2).
struct LinesHomeView: View {
    @EnvironmentObject private var trackingState: TrackingState
    @ObservedObject var recentStore: LinesRecentStore

    @State private var searchText = ""
    @State private var selectedFilter: LinesFilter = .all

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                searchField
                filterChips

                if !recentStore.lines.isEmpty {
                    recentSection
                }

                searchResultsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(WIMBShellColors.screenBackground.ignoresSafeArea())
        .navigationTitle(WIMBL10n.tabLines)
        .navigationBarTitleDisplayMode(.large)
    }

    private var searchField: some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(WIMBColors.secondaryLabel)
                TextField(WIMBL10n.linesSearchPlaceholder, text: $searchText)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await trackingState.searchLines(query: searchText) }
                    }
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 48)

            Button {
                Task { await trackingState.searchLines(query: searchText) }
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
    }

    private var filterChips: some View {
        HStack(spacing: 10) {
            ForEach(LinesFilter.allCases) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    Text(filterLabel(filter))
                        .font(WIMBTypography.caption)
                        .fontWeight(selectedFilter == filter ? .semibold : .regular)
                        .foregroundColor(selectedFilter == filter ? .white : WIMBColors.label)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            selectedFilter == filter
                                ? WIMBShellColors.tabActive
                                : WIMBColors.surface
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            WIMBSectionHeader(WIMBL10n.linesRecentSection)

            ForEach(recentStore.lines) { line in
                lineRow(line)
            }
        }
    }

    @ViewBuilder
    private var searchResultsSection: some View {
        if trackingState.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        } else if let error = trackingState.error, filteredResults.isEmpty, !searchText.isEmpty {
            WIMBEmptyStateView(
                title: WIMBL10n.searchErrorTitle,
                systemImage: "exclamationmark.triangle",
                message: error.userMessage
            )
        } else if filteredResults.isEmpty && !searchText.isEmpty {
            WIMBEmptyStateView(
                title: WIMBL10n.searchEmptyTitle,
                systemImage: "magnifyingglass",
                message: WIMBL10n.searchEmptyMessage
            )
        } else if !filteredResults.isEmpty {
            WIMBSectionHeader(WIMBL10n.searchResults)

            ForEach(filteredResults) { line in
                lineRow(line)
            }
        } else if recentStore.lines.isEmpty {
            WIMBEmptyStateView(
                title: WIMBL10n.linesEmptyTitle,
                systemImage: "bus.fill",
                message: WIMBL10n.linesEmptyMessage
            )
        }
    }

    private func filterLabel(_ filter: LinesFilter) -> String {
        switch filter {
        case .all: return WIMBL10n.linesFilterAll
        case .bus: return WIMBL10n.linesFilterBus
        }
    }

    private var filteredResults: [TransportLine] {
        switch selectedFilter {
        case .all, .bus:
            return trackingState.searchResults
        }
    }

    private func lineRow(_ line: TransportLine) -> some View {
        NavigationLink {
            LineRouteView(line: line, recentStore: recentStore)
        } label: {
            WIMBListRow {
                TripViewCell(
                    tripNumber: line.formattedNumber,
                    destination: line.routeDescription
                )
            }
        }
        .buttonStyle(.plain)
    }
}
