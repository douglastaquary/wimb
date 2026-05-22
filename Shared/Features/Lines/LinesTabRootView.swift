//
//  LinesTabRootView.swift
//  Shared
//

import SwiftUI

/// Raiz da aba Linhas com navegação em pilha.
struct LinesTabRootView: View {
    @StateObject private var recentStore = LinesRecentStore()

    var body: some View {
        NavigationStack {
            LinesHomeView(recentStore: recentStore)
        }
    }
}
