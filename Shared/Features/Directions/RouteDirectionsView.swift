//
//  RouteDirectionsView.swift
//  Shared
//

import DesignSystem
import MapFeature
import SwiftUI
import TransportEngine
import WIMBCore

/// Detalhe da rota: mapa preview, passos e live tracking (Fase 6.5).
struct RouteDirectionsView: View {
    @EnvironmentObject private var trackingState: TrackingState
    @Environment(\.dismiss) private var dismiss

    let suggestion: RouteSuggestion

    var body: some View {
        VStack(spacing: 0) {
            routeHeader

            TransportMapView(
                trackingState: trackingState,
                routeStyle: .planner,
                bottomInsetPoints: 0
            )
            .frame(height: 220)
            .clipped()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    summarySection
                    WIMBSectionHeader(WIMBL10n.routeStepsSection)
                    stepsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(WIMBShellColors.screenBackground)

            liveTrackingButton
        }
        .background(WIMBShellColors.screenBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if trackingState.trackedLines.contains(where: { $0.id == suggestion.line.id }) {
                await trackingState.selectLine(suggestion.line)
            } else {
                await trackingState.trackLine(suggestion.line)
            }
        }
    }

    private var routeHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.line.formattedNumber)
                    .font(WIMBTypography.headline)
                    .foregroundColor(.white)
                Text(suggestion.line.routeDescription)
                    .font(WIMBTypography.caption)
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
            }

            Spacer()

            Text(WIMBL10n.routeTotalMinutes(suggestion.totalMinutes))
                .font(WIMBTypography.footnote)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(WIMBShellColors.plannerHeader)
    }

    private var summarySection: some View {
        HStack(spacing: 16) {
            summaryItem(icon: "clock", label: WIMBL10n.routeTotalMinutes(suggestion.totalMinutes))
            summaryItem(icon: "banknote", label: suggestion.formattedFare)
            summaryItem(icon: "figure.walk", label: WIMBL10n.routeWalkMinutes(
                suggestion.walkToBoardMinutes + suggestion.walkFromAlightMinutes
            ))
        }
    }

    private func summaryItem(icon: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(WIMBShellColors.orange)
            Text(label)
                .font(WIMBTypography.caption)
                .foregroundColor(WIMBColors.label)
        }
    }

    private var stepsSection: some View {
        VStack(spacing: 10) {
            ForEach(Array(suggestion.steps.enumerated()), id: \.element.id) { index, step in
                stepRow(step: step, index: index + 1)
            }
        }
    }

    private func stepRow(step: RouteStep, index: Int) -> some View {
        WIMBListRow {
            HStack(alignment: .top, spacing: 12) {
                stepIcon(for: step.kind)

                VStack(alignment: .leading, spacing: 4) {
                    Text(step.title)
                        .font(WIMBTypography.footnote)
                        .foregroundColor(WIMBColors.label)
                        .multilineTextAlignment(.leading)

                    if let subtitle = step.subtitle {
                        Text(subtitle)
                            .font(WIMBTypography.caption)
                            .foregroundColor(WIMBColors.secondaryLabel)
                    }

                    Text(WIMBL10n.routeStepMinutes(step.durationMinutes))
                        .font(WIMBTypography.caption)
                        .foregroundColor(WIMBShellColors.tabActive)
                }

                Spacer()

                Text("\(index)")
                    .font(WIMBTypography.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)
            }
        }
    }

    private func stepIcon(for kind: RouteStep.Kind) -> some View {
        let symbol = kind == .walk ? "figure.walk" : "bus.fill"
        let color = kind == .walk ? WIMBShellColors.orange : WIMBShellColors.tabActive

        return Image(systemName: symbol)
            .font(.title3)
            .foregroundColor(color)
            .frame(width: 28)
    }

    private var liveTrackingButton: some View {
        NavigationLink {
            LiveLineTrackingView(line: suggestion.line)
        } label: {
            Text(WIMBL10n.liveTrackingButton)
                .font(WIMBTypography.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(WIMBShellColors.tabActive)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(WIMBColors.surface)
    }
}
