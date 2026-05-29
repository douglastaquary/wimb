//
//  SPTransConfiguration.swift
//  NetworkClient
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

/// Configuração do cliente SPTrans.
///
/// Contém as informações necessárias para conectar com a API OlhoVivo.
///
/// ## Segurança
/// O token NÃO deve ser commitado no código-fonte.
/// Use variáveis de ambiente ou Keychain.
///
/// ## Exemplo de uso
/// ```swift
/// // Usando variável de ambiente
/// let config = SPTransConfiguration.fromEnvironment()
///
/// // Configuração manual (apenas para desenvolvimento)
/// let config = SPTransConfiguration(token: "seu-token-aqui")
/// ```
public struct SPTransConfiguration: Sendable {
    
    /// URL base da API SPTrans OlhoVivo.
    public let baseURL: URL
    
    /// Token de autenticação.
    public let token: String
    
    /// Timeout para requisições em segundos.
    public let timeout: TimeInterval
    
    /// Cria uma configuração com os parâmetros especificados.
    /// - Parameters:
    ///   - baseURL: URL base da API.
    ///   - token: Token de autenticação.
    ///   - timeout: Timeout em segundos (default: 30).
    public init(
        baseURL: URL = URL(string: "http://api.olhovivo.sptrans.com.br/v2.1")!,
        token: String,
        timeout: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.token = token
        self.timeout = timeout
    }
}

// MARK: - Factory Methods

extension SPTransConfiguration {
    
    /// Cria configuração a partir de variável de ambiente.
    ///
    /// Busca o token na variável `SPTRANS_TOKEN`.
    ///
    /// - Returns: Configuração com token do ambiente.
    /// - Note: Retorna configuração com token vazio se a variável não existir.
    public static func fromEnvironment() -> SPTransConfiguration {
        let token = ProcessInfo.processInfo.environment["SPTRANS_TOKEN"] ?? ""
        return SPTransConfiguration(token: token)
    }
    
    /// Verifica se a configuração é válida.
    public var isValid: Bool {
        !token.isEmpty
    }
}
