//
//  LikeDTO.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import Foundation

struct LikeDTO: Decodable {
    
    var photo: Photo
    
    struct Photo: Decodable {
        var id: String
        var likes: Int
        var likedByUser: Bool
    }
    
    
}
