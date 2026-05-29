//
//  WIMBMainTabBar.swift
//  DesignSystem
//

import SwiftUI

/// Item da tab bar principal.
public struct WIMBTabItem: Identifiable {
    public let id: String
    public let title: String
    public let systemImage: String

    public init(id: String, title: String, systemImage: String) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
    }
}

/// Tab bar inferior com 3 abas (Direções · Estações · Linhas).
public struct WIMBMainTabBar: View {
    private let items: [WIMBTabItem]
    @Binding private var selectedID: String

    public init(items: [WIMBTabItem], selectedID: Binding<String>) {
        self.items = items
        self._selectedID = selectedID
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                Button {
                    selectedID = item.id
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: 22, weight: .medium))
                        Text(item.title)
                            .font(.caption2)
                            .fontWeight(selectedID == item.id ? .semibold : .regular)
                    }
                    .foregroundColor(selectedID == item.id ? WIMBShellColors.tabActive : WIMBShellColors.tabInactive)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 6)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedID == item.id ? .isSelected : [])
            }
        }
        .background(WIMBColors.surface)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}
