//
//  WIMBError.swift
//  WIMBCore
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

/// Erros do domínio WIMB.
///
/// Centraliza todos os tipos de erro que podem ocorrer no app,
/// fornecendo mensagens localizadas e informações de contexto.
///
/// ## Categorias de Erro
/// - **Autenticação**: Problemas com credenciais ou token.
/// - **Rede**: Falhas de comunicação com a API.
/// - **Dados**: Problemas de decodificação ou dados inválidos.
/// - **Recursos**: Entidades não encontradas.
/// - **Permissões**: Acesso negado a recursos do sistema.
public enum WIMBError: Error, Sendable {
    
    // MARK: - Authentication
    
    /// Falha na autenticação com a API.
    case authenticationFailed
    
    /// Token expirado ou inválido.
    case tokenExpired
    
    // MARK: - Network
    
    /// Erro de rede genérico.
    case networkError(underlying: Error)
    
    /// Tempo limite excedido.
    case timeout
    
    /// Servidor retornou erro.
    case serverError(statusCode: Int)
    
    // MARK: - Data
    
    /// Erro ao decodificar resposta.
    case decodingError(underlying: Error)
    
    /// Resposta inválida ou inesperada.
    case invalidResponse
    
    /// Dados ausentes ou vazios.
    case noData
    
    // MARK: - Resources
    
    /// Linha de transporte não encontrada.
    case lineNotFound(id: Int)
    
    /// Parada não encontrada.
    case stopNotFound(id: Int)
    
    /// Nenhum veículo disponível.
    case noVehiclesAvailable

    /// Limite de linhas rastreadas simultaneamente excedido.
    case tooManyTrackedLines(max: Int)
    
    // MARK: - Permissions
    
    /// Permissão de localização negada.
    case locationPermissionDenied
    
    /// Serviços de localização desabilitados.
    case locationServicesDisabled
}

// MARK: - LocalizedError

extension WIMBError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Falha na autenticação com a API SPTrans"
            
        case .tokenExpired:
            return "Sessão expirada. Por favor, tente novamente."
            
        case .networkError(let error):
            return "Erro de rede: \(error.localizedDescription)"
            
        case .timeout:
            return "Tempo limite excedido. Verifique sua conexão."
            
        case .serverError(let statusCode):
            return "Erro do servidor (código \(statusCode))"
            
        case .decodingError(let error):
            return "Erro ao processar dados: \(error.localizedDescription)"
            
        case .invalidResponse:
            return "Resposta inválida do servidor"
            
        case .noData:
            return "Nenhum dado disponível"
            
        case .lineNotFound(let id):
            return "Linha \(id) não encontrada"
            
        case .stopNotFound(let id):
            return "Parada \(id) não encontrada"
            
        case .noVehiclesAvailable:
            return "Nenhum veículo disponível no momento"

        case .tooManyTrackedLines(let max):
            return "Limite de \(max) linhas simultâneas atingido"
            
        case .locationPermissionDenied:
            return "Permissão de localização negada. Habilite nas Configurações."
            
        case .locationServicesDisabled:
            return "Serviços de localização desabilitados no dispositivo"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .authenticationFailed:
            return "O token de acesso pode estar incorreto ou expirado."
            
        case .networkError:
            return "Não foi possível conectar ao servidor."
            
        case .timeout:
            return "A requisição demorou muito para responder."
            
        case .serverError(let statusCode):
            return "O servidor retornou status HTTP \(statusCode)."
            
        case .decodingError:
            return "O formato dos dados recebidos é inesperado."
            
        case .noVehiclesAvailable:
            return "Pode não haver veículos em operação nesta linha."
            
        default:
            return nil
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .authenticationFailed, .tokenExpired:
            return "Reinicie o aplicativo ou verifique sua conexão."
            
        case .networkError, .timeout:
            return "Verifique sua conexão com a internet e tente novamente."
            
        case .serverError:
            return "Tente novamente em alguns minutos."
            
        case .locationPermissionDenied:
            return "Vá em Ajustes > Privacidade > Localização para habilitar."
            
        case .locationServicesDisabled:
            return "Habilite os serviços de localização nas Configurações do dispositivo."
            
        default:
            return "Tente novamente."
        }
    }
}

// MARK: - Equatable

extension WIMBError: Equatable {
    public static func == (lhs: WIMBError, rhs: WIMBError) -> Bool {
        switch (lhs, rhs) {
        case (.authenticationFailed, .authenticationFailed),
             (.tokenExpired, .tokenExpired),
             (.timeout, .timeout),
             (.invalidResponse, .invalidResponse),
             (.noData, .noData),
             (.noVehiclesAvailable, .noVehiclesAvailable),
             (.locationPermissionDenied, .locationPermissionDenied),
             (.locationServicesDisabled, .locationServicesDisabled):
            return true

        case (.tooManyTrackedLines(let lhsMax), .tooManyTrackedLines(let rhsMax)):
            return lhsMax == rhsMax
            
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
            
        case (.lineNotFound(let lhsId), .lineNotFound(let rhsId)):
            return lhsId == rhsId
            
        case (.stopNotFound(let lhsId), .stopNotFound(let rhsId)):
            return lhsId == rhsId
            
        default:
            return false
        }
    }
}
