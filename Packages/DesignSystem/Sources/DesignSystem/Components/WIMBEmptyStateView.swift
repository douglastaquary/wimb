//
//  WIMBEmptyStateView.swift
//  DesignSystem
//

import SwiftUI

/// Estado vazio compatível com iOS 16.
public struct WIMBEmptyStateView: View {
    let title: String
    let systemImage: String
    let message: String

    public init(title: String, systemImage: String, message: String) {
        self.title = title
        self.systemImage = systemImage
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundColor(WIMBColors.secondaryLabel)
            Text(title)
                .font(WIMBTypography.headline)
            Text(message)
                .font(WIMBTypography.subheadline)
                .foregroundColor(WIMBColors.secondaryLabel)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

private extension WIMBTypography {
    static let subheadline = Font.subheadline
}
