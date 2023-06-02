//
//  PhotoDTO.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import Foundation

struct PhotoDTO: Decodable {
    
    var id: String
    var slug: String
    var createdAt: Date
    var updatedAt: Date
    var promotedAt: Date?
    var width: Int
    var height: Int
    var color: String?
    var description: String?
    var altDescription: String?
    var urls: URLs
    var links: Links
    var likes: Int
    var likedByUser: Bool
    var user: UserDTO
    var exif: Exif?
    var location: Location?
    
    struct URLs: Decodable {
        
        var raw: URL
        var full: URL
        var regular: URL
        var small: URL
        var thumb: URL
        
    }
    
    struct Links: Decodable {
        
        var html, download: URL
        
    }
    
    struct Location: Decodable {
        
        var city: String?
        var country: String?
        var postition: Postition
        
        struct Postition: Decodable {
            
            var latitude: Double
            var longtitude: Double
            
        }
        
    }
    
    struct Exif: Decodable {
        
        var make: String
        var model: String
        var name: String
        var exposureTime: String
        var aperture: String
        var focalLenght: String
        var iso: Int
        
    }
    
}


