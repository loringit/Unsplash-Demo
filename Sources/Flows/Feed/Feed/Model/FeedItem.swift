//
//  FeedItem.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 03.06.2023.
//

import Foundation

struct FeedItem {
    
    let id: String
    let ratio: CGFloat
    let description: String?
    let altDescription: String?
    let fullURL: URL
    let smallURL: URL
    let shareURL: URL
    let downloadURL: URL
    let properties: [String: String]?
    let isLiked: Bool
    let user: ShortUser
    
}

extension FeedItem: Equatable {
    
    static func == (lhs: FeedItem, rhs: FeedItem) -> Bool {
        return lhs.id == rhs.id
    }
    
}

extension FeedItem: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

struct ShortUser {
    
    let id: String
    let name: String
    let profileImageURL: URL
    
}
