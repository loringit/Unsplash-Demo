//
//  ProfileCounters.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import Foundation

struct ProfileCountersModel {
    
    let likesCount: Int
    let followersCount: Int
    let followingCount: Int
    
    init(dto: UserDTO) {
        self.likesCount = dto.totalLikes
        self.followersCount = dto.followersCount ?? 0
        self.followingCount = dto.followingCount ?? 0
    }
    
}


