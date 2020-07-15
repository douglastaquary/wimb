//
//  APISPTrans.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 12/07/20.
//

import Foundation
import Combine

enum APISPTrans {
    static let wimbAPI = WimbApiService()
    public static let baseURL = URL(string: "http://api.olhovivo.sptrans.com.br/v2.1")!
    public static let token = "f89300e7615320c82cb1d9911d26c3dba054338ba9c39059bc2d9a414091ece8"
}

public enum SPTransEndpoint: String {
    case auth = "/Login/Autenticar"
    case trips = "/Linha/Buscar"
    case arrivals = "/Previsao/Linha"
}

extension APISPTrans {
    
    static func fetchTrips(text: String, _ path: SPTransEndpoint) -> AnyPublisher<[Trip], Error> {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path.rawValue), resolvingAgainstBaseURL: true)
            else { fatalError("Couldn't create URLComponents") }
        components.queryItems = [URLQueryItem(name: "termosBusca", value: text)]
        
        let request = URLRequest(url: components.url!)
        
        return wimbAPI.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    static func performTripArrives(to tripNumber: Int, _ path: SPTransEndpoint) -> AnyPublisher<ArrivalOfVehiclesPerTrip, Error> {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path.rawValue), resolvingAgainstBaseURL: true)
            else { fatalError("Couldn't create URLComponents") }
        components.queryItems = [URLQueryItem(name: "codigoLinha", value: "\(tripNumber)")]
        
        let request = URLRequest(url: components.url!)
        
        return wimbAPI.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    static func checkAuth(_ path: SPTransEndpoint) -> AnyPublisher<Bool, Error> {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path.rawValue), resolvingAgainstBaseURL: true)
            else { fatalError("Couldn't create URLComponents") }
        components.queryItems = [URLQueryItem(name: "token", value: token)]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        
        return wimbAPI.auth(request)
            .map { _ in
                return true
            }
            .eraseToAnyPublisher()
    }
}


