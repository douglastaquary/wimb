//
//  DirectionsTabPlaceholder.swift
//  AppShell
//

import DesignSystem
import SwiftUI

/// Home da aba Direções (Fase 6.1).
struct DirectionsTabPlaceholder: View {
    let strings: ShellDisplayStrings

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroHeader
                placeholderCard
                    .padding(.horizontal, 16)
                    .padding(.top, -28)
            }
        }
        .background(WIMBShellColors.screenBackground.ignoresSafeArea())
    }

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [WIMBShellColors.heroGradientTop, WIMBShellColors.heroGradientBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 220)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(strings.regionTitle)
                        .font(WIMBTypography.caption)
                        .foregroundColor(.white.opacity(0.85))
                    Spacer()
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.white.opacity(0.9))
                }

                Text(strings.directionsPrompt)
                    .font(WIMBTypography.title)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 0) {
                    Text(strings.directionsSearchPlaceholder)
                        .font(WIMBTypography.body)
                        .foregroundColor(WIMBColors.secondaryLabel)
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 48)

                    ZStack {
                        WIMBShellColors.orange
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 52, height: 48)
                }
                .background(WIMBColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 44)
        }
    }

    private var placeholderCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(strings.comingSoonTitle, systemImage: "clock.arrow.circlepath")
                .font(WIMBTypography.headline)
                .foregroundColor(WIMBColors.label)

            Text(strings.directionsComingSoonMessage)
                .font(WIMBTypography.footnote)
                .foregroundColor(WIMBColors.secondaryLabel)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(WIMBColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
    }
}
