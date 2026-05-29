//
//  WIMBListRow.swift
//  DesignSystem
//

import SwiftUI

/// Linha estilo card para listas no bottom sheet.
public struct WIMBListRow<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WIMBColors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// Cabeçalho de seção para painéis.
public struct WIMBSectionHeader: View {
    let title: String

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(WIMBTypography.caption)
            .foregroundColor(WIMBColors.secondaryLabel)
            .textCase(.uppercase)
            .tracking(0.6)
    }
}
