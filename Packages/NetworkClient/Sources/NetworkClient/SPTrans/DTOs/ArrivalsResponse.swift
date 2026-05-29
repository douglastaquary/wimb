//
//  ArrivalsResponse.swift
//  NetworkClient
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation
import WIMBCore

/// Resposta do endpoint de previsão de chegada por linha.
///
/// Contém o horário da consulta e a lista de paradas com veículos próximos.
public struct ArrivalsResponse: Codable, Sendable {
    
    /// Horário da consulta.
    public let hour: String
    
    /// Lista de paradas com previsões (pode ser nil se não houver dados).
    public let stops: [Stop]?
    
    enum CodingKeys: String, CodingKey {
        case hour = "hr"
        case stops = "ps"
    }
}
