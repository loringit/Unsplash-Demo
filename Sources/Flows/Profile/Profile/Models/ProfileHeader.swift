//
//  ProfileHeader.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import Foundation

struct ProfileHeaderModel {
    
    let name: String?
    let bio: String?
    let avatar: URL?
    
    init(dto: UserDTO) {
        self.name = "\(dto.firstName ?? "") \(dto.lastName ?? "")"
        self.bio = dto.bio
        self.avatar = dto.profileImage.large
    }
    
}
