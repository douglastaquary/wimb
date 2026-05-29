//
//  PositionsResponse.swift
//  NetworkClient
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation
import WIMBCore

/// Resposta do endpoint de posições de veículos.
///
/// Contém o horário da consulta e a lista de veículos.
public struct PositionsResponse: Codable, Sendable {
    
    /// Horário da consulta.
    public let hour: String
    
    /// Lista de veículos (pode ser nil se não houver veículos).
    public let vehicles: [Vehicle]?
    
    enum CodingKeys: String, CodingKey {
        case hour = "hr"
        case vehicles = "vs"
    }
}
