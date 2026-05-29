//
//  WIMBRouteSuggestionCard.swift
//  DesignSystem
//

import SwiftUI
import WIMBCore

/// Conteúdo exibido no card de rota sugerida.
public struct RouteSuggestionCardContent {
    public let lineNumber: String
    public let routeDescription: String
    public let totalMinutesLabel: String
    public let fareLabel: String
    public let walkSummaryLabel: String
    public let busSummaryLabel: String

    public init(
        lineNumber: String,
        routeDescription: String,
        totalMinutesLabel: String,
        fareLabel: String,
        walkSummaryLabel: String,
        busSummaryLabel: String
    ) {
        self.lineNumber = lineNumber
        self.routeDescription = routeDescription
        self.totalMinutesLabel = totalMinutesLabel
        self.fareLabel = fareLabel
        self.walkSummaryLabel = walkSummaryLabel
        self.busSummaryLabel = busSummaryLabel
    }
}

/// Card de rota sugerida (Fase 6.5).
public struct WIMBRouteSuggestionCard: View {
    private let content: RouteSuggestionCardContent

    public init(content: RouteSuggestionCardContent) {
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(content.totalMinutesLabel)
                        .font(WIMBTypography.title)
                        .foregroundColor(WIMBColors.label)

                    Text(content.fareLabel)
                        .font(WIMBTypography.caption)
                        .foregroundColor(WIMBColors.secondaryLabel)
                }

                Spacer()

                lineBadge
            }

            Text(content.routeDescription)
                .font(WIMBTypography.footnote)
                .foregroundColor(WIMBColors.secondaryLabel)
                .lineLimit(2)

            HStack(spacing: 16) {
                summaryRow(systemImage: "figure.walk", label: content.walkSummaryLabel)
                summaryRow(systemImage: "bus.fill", label: content.busSummaryLabel)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WIMBColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    private var lineBadge: some View {
        Text(content.lineNumber)
            .font(WIMBTypography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(WIMBShellColors.tabActive)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func summaryRow(systemImage: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption)
                .foregroundColor(WIMBShellColors.orange)
            Text(label)
                .font(WIMBTypography.caption)
                .foregroundColor(WIMBColors.secondaryLabel)
        }
    }
}
