//
//  TabPlaceholderContent.swift
//  AppShell
//

import DesignSystem
import SwiftUI

struct TabPlaceholderContent: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(size: 56))
                .foregroundColor(WIMBShellColors.tabActive)

            Text(title)
                .font(WIMBTypography.title)
                .foregroundColor(WIMBColors.label)

            Text(message)
                .font(WIMBTypography.body)
                .foregroundColor(WIMBColors.secondaryLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WIMBShellColors.screenBackground.ignoresSafeArea())
    }
}
