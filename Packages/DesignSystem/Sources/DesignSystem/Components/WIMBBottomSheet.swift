//
//  WIMBBottomSheet.swift
//  DesignSystem
//

import SwiftUI

/// Bottom sheet estilo Uber usando APIs nativas (iOS 16+).
public struct WIMBBottomSheet<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            handle
                .padding(.top, 10)
                .padding(.bottom, 12)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(sheetBackground)
        .clipShape(WIMBTopRoundedRectangle(radius: 20))
        .shadow(color: .black.opacity(0.16), radius: 16, y: -6)
    }

    private var handle: some View {
        Capsule()
            .fill(WIMBColors.sheetHandle)
            .frame(width: 40, height: 5)
            .frame(maxWidth: .infinity)
    }

    private var sheetBackground: some View {
        WIMBColors.surface
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [
                        WIMBColors.surfaceSecondary.opacity(0.35),
                        WIMBColors.surface
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 48)
            }
    }
}
