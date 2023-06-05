//
//  FeedItem.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 03.06.2023.
//

import Foundation

struct PhotoItem {
    
    let id: String
    let ratio: CGFloat
    let description: String?
    let altDescription: String?
    let fullURL: URL
    let mediumURL: URL
    let smallURL: URL
    let shareURL: URL
    let downloadURL: URL
    let properties: [String: String]?
    var isLiked: Bool
    let user: ShortUser
    
}

extension PhotoItem: Equatable {
    
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        return lhs.id == rhs.id
    }
    
}

extension PhotoItem: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

extension PhotoItem {
    
    static func mapFromDTO(_ dto: PhotoDTO) -> PhotoItem {
        let properties = [
            "Make": dto.exif?.make ?? "-",
            "Model": dto.exif?.model ?? "-",
            "Shutter speed": dto.exif?.exposureTime ?? "-",
            "Aperture": dto.exif?.aperture ?? "-",
            "Focal Length": dto.exif?.focalLenght ?? "-",
            "ISO": dto.exif?.iso != nil ? "\(dto.exif!.iso)" : "-",
            "Dimensions": "\(dto.width) x \(dto.height)"
        ]
        
        return PhotoItem(
            id: dto.id,
            ratio: CGFloat(dto.width) / CGFloat(dto.height),
            description: dto.description,
            altDescription: dto.altDescription,
            fullURL: dto.urls.full,
            mediumURL: dto.urls.regular,
            smallURL: dto.urls.small,
            shareURL: dto.links.html,
            downloadURL: dto.links.download,
            properties: properties,
            isLiked: dto.likedByUser,
            user: ShortUser(
                id: dto.user.id,
                name: "\(dto.user.firstName ?? "") \(dto.user.lastName ?? "")",
                profileImageURL: dto.user.profileImage.medium
            )
        )
    }
    
}

struct ShortUser {
    
    let id: String
    let name: String
    let profileImageURL: URL
    
}
