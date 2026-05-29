//
//  LiveTrackingHeader.swift
//  MapFeature
//

import DesignSystem
import SwiftUI

/// Header flutuante do live tracking (Fase 6.3).
public struct LiveTrackingHeader: View {
    private let title: String
    private let subtitle: String?
    private let closeAccessibilityLabel: String
    private let routeAccessibilityLabel: String
    private let onClose: () -> Void
    private let onShowRoute: () -> Void

    public init(
        title: String,
        subtitle: String?,
        closeAccessibilityLabel: String,
        routeAccessibilityLabel: String,
        onClose: @escaping () -> Void,
        onShowRoute: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.closeAccessibilityLabel = closeAccessibilityLabel
        self.routeAccessibilityLabel = routeAccessibilityLabel
        self.onClose = onClose
        self.onShowRoute = onShowRoute
    }

    public var body: some View {
        HStack(spacing: 12) {
            headerButton(systemImage: "xmark", accessibilityLabel: closeAccessibilityLabel, action: onClose)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(WIMBTypography.headline)
                    .foregroundColor(WIMBColors.label)
                    .lineLimit(1)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(WIMBTypography.caption)
                        .foregroundColor(WIMBColors.secondaryLabel)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            headerButton(systemImage: "point.topleft.down.curvedto.point.bottomright.up", accessibilityLabel: routeAccessibilityLabel, action: onShowRoute)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(WIMBColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 2)
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    private func headerButton(systemImage: String, accessibilityLabel: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(WIMBColors.label)
                .frame(width: 36, height: 36)
                .background(WIMBColors.surfaceSecondary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
