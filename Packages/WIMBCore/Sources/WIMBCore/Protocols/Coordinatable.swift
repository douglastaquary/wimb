//
//  Coordinatable.swift
//  WIMBCore
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

/// Protocolo para elementos que podem ser exibidos em um mapa.
///
/// Fornece uma interface comum para veículos, paradas e outros
/// pontos de interesse que precisam ser renderizados no mapa.
///
/// ## Conformance Requirements
/// - `coordinate`: Posição geográfica do elemento.
/// - `displayTitle`: Título para exibição (ex: nome, número).
///
/// ## Optional Properties
/// - `heading`: Ângulo de direção (para veículos em movimento).
/// - `displaySubtitle`: Informação adicional.
///
/// ## Exemplo de uso
/// ```swift
/// struct CustomAnnotation: Coordinatable {
///     let id: UUID
///     let coordinate: Coordinate
///     var displayTitle: String { "Custom" }
/// }
/// ```
public protocol Coordinatable: Identifiable, Sendable {
    
    /// Posição geográfica do elemento.
    var coordinate: Coordinate { get }
    
    /// Ângulo de direção em radianos (para elementos móveis).
    var heading: Double? { get }
    
    /// Título principal para exibição.
    var displayTitle: String { get }
    
    /// Subtítulo ou informação secundária.
    var displaySubtitle: String? { get }
}

// MARK: - Default Implementations

extension Coordinatable {
    
    /// Direção padrão (sem rotação).
    public var heading: Double? { nil }
    
    /// Subtítulo padrão (vazio).
    public var displaySubtitle: String? { nil }
}
