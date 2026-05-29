//
//  StationsTabPlaceholder.swift
//  AppShell
//

import DesignSystem
import SwiftUI

struct StationsTabPlaceholder: View {
    let strings: ShellDisplayStrings

    var body: some View {
        TabPlaceholderContent(
            systemImage: "mappin.circle.fill",
            title: strings.tabStations,
            message: strings.stationsPlaceholderMessage
        )
    }
}
