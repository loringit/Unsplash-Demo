//
//  ProfileLinks.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import Foundation

struct ProfileLinksModel {
    
    let twitter: URL?
    let instagram: URL?
    let website: URL?
    
    init(dto: UserDTO) {
        self.website = dto.portfolioUrl
        
        if let twitterName = dto.twitterUsername, let twitterURL = URL(string: "https://www.twitter.com/\(twitterName)") {
            self.twitter = twitterURL
        } else {
            self.twitter = nil
        }
        
        if let instagramName = dto.instagramUsername, let instagramURL = URL(string: "https://www.instagram.com/\(instagramName)") {
            self.instagram = instagramURL
        } else {
            self.instagram = nil
        }
    }
    
}
