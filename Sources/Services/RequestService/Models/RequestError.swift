//
//  RequestError.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import Foundation

enum RequestError: Error {
    
    case unknown
    case timeout
    case badRequest(Error)
    case notHttpResponse
    case noData
    case serverError(Any)
    case noToken
    case badInput
    
}
