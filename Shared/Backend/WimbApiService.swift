//
//  WimbAPI.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 12/07/20.
//

import Foundation
import Combine

public struct WimbApiService {
    
    func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                let value = try JSONDecoder().decode(T.self, from: result.data)
                print("\nResponse:\n\(value)\n")
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher() 
    }
    
    func auth(_ request: URLRequest) -> AnyPublisher<Bool, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Bool in
                let value = String(data: result.data, encoding: .utf8)
                print("\nValue: \(String(describing: value))")
                return true
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}
