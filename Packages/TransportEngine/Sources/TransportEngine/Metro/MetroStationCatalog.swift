//
//  MetroStationCatalog.swift
//  TransportEngine
//

import Foundation
import WIMBCore

/// Estações principais do metrô de São Paulo (dados estáticos).
enum MetroStationCatalog {
    static let stations: [MetroStation] = [
        MetroStation(
            id: "se",
            name: "Sé",
            lines: ["1-Azul", "3-Vermelha"],
            coordinate: Coordinate(latitude: -23.5505, longitude: -46.6333)
        ),
        MetroStation(
            id: "paulista",
            name: "Paulista",
            lines: ["2-Verde", "4-Amarela"],
            coordinate: Coordinate(latitude: -23.5558, longitude: -46.6623)
        ),
        MetroStation(
            id: "pinheiros",
            name: "Pinheiros",
            lines: ["4-Amarela", "9-Esmeralda"],
            coordinate: Coordinate(latitude: -23.5673, longitude: -46.7034)
        ),
        MetroStation(
            id: "luz",
            name: "Luz",
            lines: ["1-Azul", "4-Amarela"],
            coordinate: Coordinate(latitude: -23.5354, longitude: -46.6356)
        ),
        MetroStation(
            id: "tatuape",
            name: "Tatuapé",
            lines: ["3-Vermelha", "11-Coral"],
            coordinate: Coordinate(latitude: -23.5406, longitude: -46.5765)
        ),
        MetroStation(
            id: "vila-madalena",
            name: "Vila Madalena",
            lines: ["2-Verde"],
            coordinate: Coordinate(latitude: -23.5467, longitude: -46.6932)
        ),
        MetroStation(
            id: "butanta",
            name: "Butantã",
            lines: ["4-Amarela"],
            coordinate: Coordinate(latitude: -23.5712, longitude: -46.7085)
        ),
        MetroStation(
            id: "barra-funda",
            name: "Barra Funda",
            lines: ["3-Vermelha", "7-Rubi"],
            coordinate: Coordinate(latitude: -23.5256, longitude: -46.6674)
        ),
        MetroStation(
            id: "republica",
            name: "República",
            lines: ["3-Vermelha", "4-Amarela"],
            coordinate: Coordinate(latitude: -23.5434, longitude: -46.6432)
        ),
        MetroStation(
            id: "consolacao",
            name: "Consolação",
            lines: ["2-Verde", "4-Amarela"],
            coordinate: Coordinate(latitude: -23.5512, longitude: -46.6593)
        ),
        MetroStation(
            id: "jabaquara",
            name: "Jabaquara",
            lines: ["1-Azul"],
            coordinate: Coordinate(latitude: -23.6467, longitude: -46.6422)
        ),
        MetroStation(
            id: "santana",
            name: "Santana",
            lines: ["1-Azul"],
            coordinate: Coordinate(latitude: -23.5028, longitude: -46.6238)
        ),
        MetroStation(
            id: "praca-arca",
            name: "Praça da Árvore",
            lines: ["1-Azul"],
            coordinate: Coordinate(latitude: -23.6108, longitude: -46.6372)
        ),
        MetroStation(
            id: "carrão",
            name: "Carrão",
            lines: ["3-Vermelha"],
            coordinate: Coordinate(latitude: -23.5478, longitude: -46.5497)
        ),
        MetroStation(
            id: "morumbi",
            name: "Morumbi",
            lines: ["4-Amarela", "9-Esmeralda"],
            coordinate: Coordinate(latitude: -23.6234, longitude: -46.6997)
        )
    ]
}
