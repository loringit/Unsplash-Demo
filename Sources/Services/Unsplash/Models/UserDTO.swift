//
//  UserDTO.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import Foundation

struct UserDTO: Decodable {
    
    var id: String
    var updatedAt: Date
    var username: String
    var firstName: String?
    var lastName: String?
    
    var bio: String?
    var location: String?
    var portfoliUrl: URL?
    var instagramUsername: String?
    var twitterUsername: String?
    
    var totalCollections: Int
    var totalLikes: Int
    var totalPhotos: Int
    var followersCount: Int?
    var followingCount: Int?
    
    var links: Links
    var profileImage: ProfileImageURLs
    
    struct ProfileImageURLs: Decodable {
        
        var small, medium, large: URL
        
    }
    
    struct Links: Decodable {
        
        var html: URL
        
    }
    
}
