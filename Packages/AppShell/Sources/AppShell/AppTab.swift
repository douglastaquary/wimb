//
//  AppTab.swift
//  AppShell
//

import Foundation

/// Abas principais do app.
public enum AppTab: String, CaseIterable, Identifiable, Sendable {
    case directions
    case stations
    case lines

    public var id: String { rawValue }
}
