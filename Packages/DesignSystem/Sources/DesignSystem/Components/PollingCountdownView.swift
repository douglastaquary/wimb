//
//  PollingCountdownView.swift
//  DesignSystem
//

import SwiftUI

/// Contagem regressiva até a próxima atualização automática.
public struct PollingCountdownView: View {
    private let lastUpdate: Date?
    private let interval: TimeInterval
    private let label: (Int) -> String

    public init(
        lastUpdate: Date?,
        interval: TimeInterval,
        label: @escaping (Int) -> String
    ) {
        self.lastUpdate = lastUpdate
        self.interval = interval
        self.label = label
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            Text(label(secondsRemaining(at: context.date)))
                .font(WIMBTypography.caption)
                .foregroundColor(WIMBColors.secondaryLabel)
                .monospacedDigit()
        }
    }

    private func secondsRemaining(at date: Date) -> Int {
        guard let lastUpdate = lastUpdate else {
            return Int(interval.rounded())
        }

        let elapsed = date.timeIntervalSince(lastUpdate)
        let remaining = max(0, interval - elapsed)
        return Int(remaining.rounded(.up))
    }
}
