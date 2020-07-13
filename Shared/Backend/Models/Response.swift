//
//  Response.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 12/07/20.
//

import Foundation

public struct Response<T> { 
    let value: T
    let response: URLResponse
}

