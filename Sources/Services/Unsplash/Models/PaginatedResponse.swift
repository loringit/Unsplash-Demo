//
//  PaginatedResponse.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import Foundation

struct PaginatedResponse<T: Decodable>: Decodable {
    
    var total: Int
    var totalPages: Int
    var results: [T]
    
}
