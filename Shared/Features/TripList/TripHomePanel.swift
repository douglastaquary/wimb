//
//  TripHomePanel.swift
//  Shared
//

import DesignSystem
import SwiftUI
import TransportEngine
import WIMBCore

/// Painel principal do bottom sheet: busca ou detalhe da linha.
struct TripHomePanel: View {
    @EnvironmentObject private var trackingState: TrackingState

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            panelHeader

            Divider()
                .opacity(0.35)

            if let line = trackingState.selectedLine {
                TripLineDetailPanel(line: line)
            } else {
                TripSearchContent()
            }
        }
    }

    private var panelHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            if trackingState.selectedLine != nil {
                Button {
                    Task {
                        await trackingState.selectLine(nil)
                    }
                } label: {
                    Label(WIMBL10n.back, systemImage: "chevron.left")
                        .font(WIMBTypography.headline)
                        .foregroundColor(WIMBColors.primary)
                }
                .buttonStyle(.plain)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(WIMBL10n.homeTitle)
                        .font(WIMBTypography.title)
                    Text(WIMBL10n.homeSubtitle)
                        .font(WIMBTypography.caption)
                        .foregroundColor(WIMBColors.secondaryLabel)
                }
            }

            Spacer()

            if let lastUpdate = trackingState.lastUpdate {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(WIMBL10n.updated)
                        .font(.caption2)
                        .foregroundColor(WIMBColors.secondaryLabel)
                    Text(lastUpdate, style: .time)
                        .font(WIMBTypography.caption)
                        .foregroundColor(WIMBColors.label)
                }
            }
        }
    }
}

/// Conteúdo de busca.
private struct TripSearchContent: View {
    @EnvironmentObject private var trackingState: TrackingState
    @State private var searchText = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if !trackingState.trackedLines.isEmpty {
                    trackedLinesSection
                }

                SearchBarView(searchText: $searchText) {
                    Task {
                        await trackingState.searchLines(query: searchText)
                    }
                }

                searchResultsSection
            }
        }
        .frame(maxHeight: 340)
    }

    private var trackedLinesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            WIMBSectionHeader(WIMBL10n.trackingSection)

            ForEach(trackingState.trackedLines) { line in
                HStack(spacing: 8) {
                    Button {
                        Task {
                            await trackingState.selectLine(line)
                        }
                    } label: {
                        WIMBListRow {
                            TripViewCell(
                                tripNumber: line.formattedNumber,
                                destination: line.routeDescription
                            )
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                        Task {
                            await trackingState.untrackLine(line.id)
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(WIMBColors.secondaryLabel)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(WIMBL10n.trackingStop(lineNumber: line.formattedNumber))
                }
            }
        }
    }

    @ViewBuilder
    private var searchResultsSection: some View {
        if trackingState.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        } else if let error = trackingState.error, trackingState.searchResults.isEmpty {
            WIMBEmptyStateView(
                title: WIMBL10n.searchErrorTitle,
                systemImage: "exclamationmark.triangle",
                message: error.localizedDescription
            )
        } else if trackingState.searchResults.isEmpty && !searchText.isEmpty {
            WIMBEmptyStateView(
                title: WIMBL10n.searchEmptyTitle,
                systemImage: "magnifyingglass",
                message: WIMBL10n.searchEmptyMessage
            )
        } else if !trackingState.searchResults.isEmpty {
            WIMBSectionHeader(WIMBL10n.searchResults)

            ForEach(trackingState.searchResults) { line in
                let isTracked = trackingState.trackedLines.contains(where: { $0.id == line.id })

                Button {
                    Task {
                        if isTracked {
                            await trackingState.selectLine(line)
                        } else {
                            await trackingState.trackLine(line)
                            await trackingState.selectLine(line)
                        }
                    }
                } label: {
                    WIMBListRow {
                        TripViewCell(
                            tripNumber: line.formattedNumber,
                            destination: line.routeDescription
                        )
                        .opacity(isTracked ? 0.85 : 1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
