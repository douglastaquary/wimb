//
//  WIMBAppEnvironment.swift
//  WhereIsMyBus
//
//  Bootstrap da arquitetura SPM.
//

import Foundation
import NetworkClient
import TransportEngine

/// Factory central para dependências da aplicação.
enum WIMBAppEnvironment {
    /// Cria o estado de rastreamento com cliente SPTrans configurado.
    @MainActor
    static func makeTrackingState() -> TrackingState {
        let configuration = SPTransConfiguration(token: resolveSPTransToken())
        let client = SPTransClient(configuration: configuration)
        return TrackingState(client: client)
    }

    private static func resolveSPTransToken() -> String {
        if let token = ProcessInfo.processInfo.environment["SPTRANS_TOKEN"], !token.isEmpty {
            return token
        }

        return SPTransCredentials.developmentToken
    }
}

/// Token de desenvolvimento — substituir por Keychain ou variável de ambiente em produção.
enum SPTransCredentials {
    static let developmentToken = "f89300e7615320c82cb1d9911d26c3dba054338ba9c39059bc2d9a414091ece8"
}
