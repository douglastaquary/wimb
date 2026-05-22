//
//  WIMBError+UserMessage.swift
//  Shared
//

import WIMBCore

extension WIMBError {
    /// Mensagem simples para mostrar na tela (pt-BR / en via Localizable).
    var userMessage: String {
        switch self {
        case .authenticationFailed, .tokenExpired:
            return WIMBL10n.errorAuth
        case .networkError:
            return WIMBL10n.errorNetwork
        case .timeout:
            return WIMBL10n.errorTimeout
        case .serverError:
            return WIMBL10n.errorServer
        case .decodingError, .invalidResponse:
            return WIMBL10n.errorGeneric
        case .noData:
            return WIMBL10n.errorNoData
        case .lineNotFound:
            return WIMBL10n.errorLineNotFound
        case .stopNotFound:
            return WIMBL10n.errorStopNotFound
        case .noVehiclesAvailable:
            return WIMBL10n.errorNoVehicles
        case .tooManyTrackedLines(let max):
            return WIMBL10n.errorTooManyLines(max: max)
        case .locationPermissionDenied:
            return WIMBL10n.errorLocationDenied
        case .locationServicesDisabled:
            return WIMBL10n.errorLocationDisabled
        }
    }
}
