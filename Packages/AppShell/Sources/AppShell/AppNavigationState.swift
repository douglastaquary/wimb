//
//  AppNavigationState.swift
//  AppShell
//

import Combine
import Foundation

/// Estado global de navegação por abas (iOS 16).
@MainActor
public final class AppNavigationState: ObservableObject {
    @Published public var selectedTab: AppTab = .directions

    public init(selectedTab: AppTab = .directions) {
        self.selectedTab = selectedTab
    }
}
