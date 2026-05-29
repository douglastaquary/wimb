//
//  Double+Truncate.swift
//  WIMBCore
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

extension Double {
    
    /// Trunca o número para um número específico de casas decimais.
    ///
    /// Diferente de `rounded()`, esta função sempre trunca para baixo.
    ///
    /// ## Exemplo
    /// ```swift
    /// let value = 23.123456789
    /// print(value.truncated(places: 4)) // 23.1234
    /// print(value.truncated(places: 2)) // 23.12
    /// ```
    ///
    /// - Parameter places: Número de casas decimais desejadas.
    /// - Returns: Valor truncado.
    public func truncated(places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return floor(multiplier * self) / multiplier
    }
    
    /// Formata o número como string com precisão específica.
    ///
    /// - Parameter places: Número de casas decimais.
    /// - Returns: String formatada.
    public func formatted(places: Int) -> String {
        String(format: "%.\(places)f", self)
    }
}
