//
//  DependancyContainer.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import Foundation

protocol IDependencyContainer: AnyObject {
    
    var unsplashService: IUnsplashService { get }
    
}

class DependencyContainer: IDependencyContainer {
    
    // MARK: - Public properties
    
    let unsplashService: IUnsplashService
    
    // MARK: - Lifecycle
    
    init(
        unsplashService: IUnsplashService
    ) {
        self.unsplashService = unsplashService
    }
    
}
