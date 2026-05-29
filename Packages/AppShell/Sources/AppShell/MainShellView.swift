//
//  MainShellView.swift
//  AppShell
//

import DesignSystem
import SwiftUI

/// Root do app com 3 abas (Fase 6.1).
public struct MainShellView<DirectionsTab: View, StationsTab: View, LinesTab: View>: View {
    @ObservedObject private var navigationState: AppNavigationState
    private let strings: ShellDisplayStrings
    private let directionsTab: DirectionsTab
    private let stationsTab: StationsTab
    private let linesTab: LinesTab

    public init(
        navigationState: AppNavigationState,
        strings: ShellDisplayStrings = .english,
        @ViewBuilder directionsTab: () -> DirectionsTab,
        @ViewBuilder stationsTab: () -> StationsTab,
        @ViewBuilder linesTab: () -> LinesTab
    ) {
        self.navigationState = navigationState
        self.strings = strings
        self.directionsTab = directionsTab()
        self.stationsTab = stationsTab()
        self.linesTab = linesTab()
    }

    public var body: some View {
        VStack(spacing: 0) {
            tabContent
            WIMBMainTabBar(items: tabItems, selectedID: selectedTabBinding)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var tabContent: some View {
        Group {
            switch navigationState.selectedTab {
            case .directions:
                directionsTab
            case .stations:
                stationsTab
            case .lines:
                linesTab
            }
        }
    }

    private var tabItems: [WIMBTabItem] {
        [
            WIMBTabItem(id: AppTab.directions.rawValue, title: strings.tabDirections, systemImage: "arrow.triangle.swap"),
            WIMBTabItem(id: AppTab.stations.rawValue, title: strings.tabStations, systemImage: "mappin.circle.fill"),
            WIMBTabItem(id: AppTab.lines.rawValue, title: strings.tabLines, systemImage: "bus.fill")
        ]
    }

    private var selectedTabBinding: Binding<String> {
        Binding(
            get: { navigationState.selectedTab.rawValue },
            set: { newValue in
                if let tab = AppTab(rawValue: newValue) {
                    navigationState.selectedTab = tab
                }
            }
        )
    }
}
