//
//  LinesTabPlaceholder.swift
//  AppShell
//

import DesignSystem
import SwiftUI

struct LinesTabPlaceholder: View {
    let strings: ShellDisplayStrings

    var body: some View {
        TabPlaceholderContent(
            systemImage: "bus.fill",
            title: strings.tabLines,
            message: strings.linesPlaceholderMessage
        )
    }
}
