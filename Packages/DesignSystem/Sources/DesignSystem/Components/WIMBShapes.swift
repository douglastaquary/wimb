//
//  WIMBShapes.swift
//  DesignSystem
//

import SwiftUI

#if canImport(UIKit)
import UIKit

/// Retângulo arredondado apenas no topo (estilo bottom sheet).
public struct WIMBTopRoundedRectangle: Shape {
    public var radius: CGFloat

    public init(radius: CGFloat = 20) {
        self.radius = radius
    }

    public func path(in rect: CGRect) -> Path {
        let corners: UIRectCorner = [.topLeft, .topRight]
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#else
public struct WIMBTopRoundedRectangle: Shape {
    public var radius: CGFloat

    public init(radius: CGFloat = 20) {
        self.radius = radius
    }

    public func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: radius, style: .continuous).path(in: rect)
    }
}
#endif
