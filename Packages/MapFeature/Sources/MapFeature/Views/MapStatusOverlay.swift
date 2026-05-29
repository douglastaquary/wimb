//
//  MapStatusOverlay.swift
//  MapFeature
//

import SwiftUI
import DesignSystem
import TransportEngine

/// Overlay superior do mapa: contagem de veículos e botão de atualizar.
public struct MapStatusOverlay: View {
    @ObservedObject private var trackingState: TrackingState
    private let strings: MapDisplayStrings
    private let onRefresh: () -> Void

    public init(
        trackingState: TrackingState,
        strings: MapDisplayStrings,
        onRefresh: @escaping () -> Void
    ) {
        self.trackingState = trackingState
        self.strings = strings
        self.onRefresh = onRefresh
    }

    public var body: some View {
        VStack {
            HStack(spacing: 12) {
                statusBadge

                if let weather = trackingState.weather {
                    WIMBWeatherChip(weather: weather)
                }

                Spacer()

                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(WIMBColors.label)
                        .frame(width: 40, height: 40)
                        .background(WIMBColors.surface)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                }
                .disabled(trackingState.isLoading)
                .accessibilityLabel(strings.refreshAccessibilityLabel)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Spacer()
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "bus.fill")
                .foregroundColor(WIMBColors.busActive)
            Text(statusText)
                .font(WIMBTypography.caption)
                .foregroundColor(WIMBColors.label)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(WIMBColors.surface)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
    }

    private var statusText: String {
        if trackingState.isTracking {
            return strings.trackingStatus(trackingState.totalVehicleCount, trackingState.trackedLines.count)
        }
        return strings.idleStatus
    }
}
