//
//  MapRouteStyle.swift
//  MapFeature
//

import UIKit

/// Estilo visual da rota no mapa.
public enum MapRouteStyle: Sendable {
    /// Planejamento / detalhe de linha (azul).
    case planner
    /// Live tracking em tempo real — foco no ônibus, sem setas de direção.
    case live

    var strokeColor: UIColor {
        switch self {
        case .planner:
            return UIColor.systemBlue.withAlphaComponent(0.85)
        case .live:
            return UIColor(red: 1.0, green: 0.843, blue: 0.0, alpha: 0.95)
        }
    }

    var lineWidth: CGFloat {
        switch self {
        case .planner: return 4
        case .live: return 5
        }
    }

    var showsDirectionArrows: Bool {
        false
    }

    var showsRoutePolyline: Bool {
        switch self {
        case .planner: return true
        case .live: return false
        }
    }
}
