//
//  TransportLine.swift
//  WIMBCore
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

/// Representa uma linha de transporte público da SPTrans.
///
/// Contém informações sobre o número da linha, terminais e direção.
///
/// ## Exemplo de uso
/// ```swift
/// let line = TransportLine(
///     id: 34041,
///     firstPartOfSign: "8000",
///     secondPartOfSign: 10,
///     direction: 1,
///     mainTerminal: "METRÔ JABAQUARA",
///     secondaryTerminal: "TERMINAL JOÃO DIAS",
///     circular: false
/// )
///
/// print(line.formattedNumber) // "8000-10"
/// print(line.routeDescription) // "METRÔ JABAQUARA → TERMINAL JOÃO DIAS"
/// ```
public struct TransportLine: Sendable, Identifiable, Hashable, Codable {
    
    // MARK: - Properties
    
    /// Código único da linha (usado internamente pela API).
    public let id: Int
    
    /// Primeira parte do letreiro (ex: "8000").
    public let firstPartOfSign: String
    
    /// Segunda parte do letreiro (ex: 10).
    public let secondPartOfSign: Int
    
    /// Sentido de operação da linha (1 ou 2).
    public let direction: Int
    
    /// Terminal principal (ponto inicial/final).
    public let mainTerminal: String
    
    /// Terminal secundário (ponto inicial/final).
    public let secondaryTerminal: String
    
    /// Indica se a linha é circular.
    public let circular: Bool
    
    // MARK: - Initialization
    
    /// Cria uma nova linha de transporte.
    /// - Parameters:
    ///   - id: Código único da linha.
    ///   - firstPartOfSign: Primeira parte do letreiro.
    ///   - secondPartOfSign: Segunda parte do letreiro.
    ///   - direction: Sentido de operação.
    ///   - mainTerminal: Terminal principal.
    ///   - secondaryTerminal: Terminal secundário.
    ///   - circular: Se é linha circular.
    public init(
        id: Int,
        firstPartOfSign: String,
        secondPartOfSign: Int,
        direction: Int,
        mainTerminal: String,
        secondaryTerminal: String,
        circular: Bool
    ) {
        self.id = id
        self.firstPartOfSign = firstPartOfSign
        self.secondPartOfSign = secondPartOfSign
        self.direction = direction
        self.mainTerminal = mainTerminal
        self.secondaryTerminal = secondaryTerminal
        self.circular = circular
    }
    
    // MARK: - CodingKeys (API SPTrans)
    
    enum CodingKeys: String, CodingKey {
        case id = "cl"
        case firstPartOfSign = "lt"
        case secondPartOfSign = "tl"
        case direction = "sl"
        case mainTerminal = "tp"
        case secondaryTerminal = "ts"
        case circular = "lc"
    }
    
    // MARK: - Computed Properties
    
    /// Número completo da linha formatado (ex: "8000-10").
    public var formattedNumber: String {
        "\(firstPartOfSign)-\(secondPartOfSign)"
    }
    
    /// Descrição completa da rota.
    public var routeDescription: String {
        "\(mainTerminal) → \(secondaryTerminal)"
    }
    
    /// Descrição curta para exibição em lista.
    public var shortDescription: String {
        "\(formattedNumber) - \(mainTerminal)"
    }
    
    /// Descrição completa incluindo número e rota.
    public var fullDescription: String {
        "\(formattedNumber) | \(routeDescription)"
    }
    
    /// Indica se a linha está no sentido de ida (direction == 1).
    public var isOutbound: Bool {
        direction == 1
    }
    
    /// Indica se a linha está no sentido de volta (direction == 2).
    public var isInbound: Bool {
        direction == 2
    }
}

// MARK: - CustomStringConvertible

extension TransportLine: CustomStringConvertible {
    public var description: String {
        "TransportLine(\(formattedNumber): \(routeDescription))"
    }
}

// MARK: - Mock Data

extension TransportLine {
    
    /// Linha de exemplo para previews e testes.
    public static let mock = TransportLine(
        id: 34041,
        firstPartOfSign: "8000",
        secondPartOfSign: 10,
        direction: 1,
        mainTerminal: "METRÔ JABAQUARA",
        secondaryTerminal: "TERMINAL JOÃO DIAS",
        circular: false
    )
}
