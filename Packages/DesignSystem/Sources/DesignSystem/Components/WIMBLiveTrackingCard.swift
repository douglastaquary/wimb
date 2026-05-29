//
//  WIMBLiveTrackingCard.swift
//  DesignSystem
//

import SwiftUI

/// Conteúdo exibido no card inferior do live tracking.
public struct LiveTrackingCardContent {
    public let lineNumber: String
    public let destination: String
    public let etaLabel: String
    public let stopsAwayLabel: String?
    public let vehiclePrefix: String?
    public let busesOnMapLabel: String
    public let lastUpdate: Date?
    public let pollingInterval: TimeInterval
    public let refreshCountdownLabel: (Int) -> String

    public init(
        lineNumber: String,
        destination: String,
        etaLabel: String,
        stopsAwayLabel: String?,
        vehiclePrefix: String?,
        busesOnMapLabel: String,
        lastUpdate: Date?,
        pollingInterval: TimeInterval,
        refreshCountdownLabel: @escaping (Int) -> String
    ) {
        self.lineNumber = lineNumber
        self.destination = destination
        self.etaLabel = etaLabel
        self.stopsAwayLabel = stopsAwayLabel
        self.vehiclePrefix = vehiclePrefix
        self.busesOnMapLabel = busesOnMapLabel
        self.lastUpdate = lastUpdate
        self.pollingInterval = pollingInterval
        self.refreshCountdownLabel = refreshCountdownLabel
    }
}

/// Card inferior do live tracking (Fase 6.3).
public struct WIMBLiveTrackingCard: View {
    private let content: LiveTrackingCardContent

    public init(content: LiveTrackingCardContent) {
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(content.lineNumber)
                        .font(WIMBTypography.caption)
                        .fontWeight(.bold)
                        .foregroundColor(WIMBColors.secondaryLabel)

                    Text(content.destination)
                        .font(WIMBTypography.headline)
                        .foregroundColor(WIMBColors.label)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Text(content.etaLabel)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(WIMBShellColors.etaLive)
            }

            if let stopsAwayLabel = content.stopsAwayLabel {
                Label(stopsAwayLabel, systemImage: "signpost.right")
                    .font(WIMBTypography.footnote)
                    .foregroundColor(WIMBColors.label)
            }

            HStack(spacing: 12) {
                Label(content.busesOnMapLabel, systemImage: "bus.fill")
                    .font(WIMBTypography.caption)
                    .foregroundColor(WIMBColors.secondaryLabel)

                if let vehiclePrefix = content.vehiclePrefix {
                    Label(vehiclePrefix, systemImage: "number")
                        .font(WIMBTypography.caption)
                        .foregroundColor(WIMBColors.secondaryLabel)
                }

                Spacer()

                PollingCountdownView(
                    lastUpdate: content.lastUpdate,
                    interval: content.pollingInterval,
                    label: content.refreshCountdownLabel
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WIMBColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 8, y: -2)
    }
}
