//
//  StationsTabRootView.swift
//  Shared
//

import SwiftUI

/// Raiz da aba Estações com navegação em pilha.
struct StationsTabRootView: View {
    var body: some View {
        NavigationStack {
            StationsHomeView()
        }
    }
}
