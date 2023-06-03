//
//  ProfileCoordinator.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import UIKit

enum ProfileCoordinatorOut {
    
    
    
}

protocol IProfileCoordinator: AnyObject {
    
    var navigationController: UINavigationController { get set }
    func start()
    var out: ((ProfileCoordinatorOut) -> ())? { get set }
    
}

class ProfileCoordinator: IProfileCoordinator{
    
    // MARK: - Public properties
    
    var navigationController: UINavigationController
    var out: ((ProfileCoordinatorOut) -> ())?
    
    // MARK: - Private properties
    
    private var dependancyContainer: IDependencyContainer
    
    // MARK: - Init
    
    init(navigationController: UINavigationController, dependancyContainer: IDependencyContainer) {
        self.navigationController = navigationController
        self.dependancyContainer = dependancyContainer
    }
    
    // MARK: - Public methods
    
    func start() {
        
    }
    
}
