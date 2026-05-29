//
//  WIMBColors.swift
//  DesignSystem
//

import SwiftUI

#if canImport(UIKit)
import UIKit

public enum WIMBColors {
    public static let primary = Color.accentColor
    public static let surface = Color(UIColor.systemBackground)
    public static let surfaceSecondary = Color(UIColor.secondarySystemBackground)
    public static let label = Color(UIColor.label)
    public static let secondaryLabel = Color(UIColor.secondaryLabel)
    public static let sheetHandle = Color(UIColor.systemGray3)
    public static let busActive = Color.blue
    public static let stopMarker = Color.green
    public static let routeLine = Color.blue.opacity(0.6)
}

#elseif canImport(AppKit)
import AppKit

public enum WIMBColors {
    public static let primary = Color.accentColor
    public static let surface = Color(NSColor.windowBackgroundColor)
    public static let surfaceSecondary = Color(NSColor.controlBackgroundColor)
    public static let label = Color(NSColor.labelColor)
    public static let secondaryLabel = Color(NSColor.secondaryLabelColor)
    public static let sheetHandle = Color(NSColor.separatorColor)
    public static let busActive = Color.blue
    public static let stopMarker = Color.green
    public static let routeLine = Color.blue.opacity(0.6)
}

#endif
