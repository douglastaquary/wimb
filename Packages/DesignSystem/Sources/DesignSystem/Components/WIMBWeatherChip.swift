//
//  WIMBWeatherChip.swift
//  DesignSystem
//

import SwiftUI
import WIMBCore

/// Chip compacto com clima atual.
public struct WIMBWeatherChip: View {
    private let weather: WeatherSnapshot

    public init(weather: WeatherSnapshot) {
        self.weather = weather
    }

    public var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
            Text("\(Int(weather.temperatureCelsius.rounded()))°")
                .font(WIMBTypography.caption)
                .foregroundColor(WIMBColors.label)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(WIMBColors.surface)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
        .accessibilityLabel(accessibilityText)
    }

    private var iconName: String {
        switch weather.condition {
        case .clear: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rain: return "cloud.rain.fill"
        case .heavyRain: return "cloud.heavyrain.fill"
        case .fog: return "cloud.fog.fill"
        }
    }

    private var iconColor: Color {
        switch weather.condition {
        case .clear: return .orange
        case .cloudy: return .gray
        case .rain, .heavyRain: return WIMBColors.primary
        case .fog: return .secondary
        }
    }

    private var accessibilityText: String {
        "Clima \(weather.condition.rawValue), \(Int(weather.temperatureCelsius.rounded())) graus"
    }
}
