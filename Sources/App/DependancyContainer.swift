//
//  DependancyContainer.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import Foundation

protocol IDependencyContainer: AnyObject {
    
    var requestService: IRequestService { get }
    var unsplashService: IUnsplashService { get }
    
}

class DependencyContainer: IDependencyContainer {
    
    // MARK: - Public properties
    
    let requestService: IRequestService
    let unsplashService: IUnsplashService
    
    // MARK: - Lifecycle
    
    init(
        requestService: IRequestService,
        unsplashService: IUnsplashService
    ) {
        self.requestService = requestService
        self.unsplashService = unsplashService
    }
    
}
