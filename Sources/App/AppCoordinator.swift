//
//  AppCoordinator.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import UIKit

enum AppCoordinatorOut {
    
    
    
}

protocol IAppCoordinator: AnyObject {
    
    var window: UIWindow { get set }
    var out: ((AppCoordinatorOut) -> ())? { get set }
    func start()
    
}

class AppCoordinator: IAppCoordinator {
    
    // MARK: - Public Properties
    
    var window: UIWindow
    var out: ((AppCoordinatorOut) -> ())?
    
    // MARK: - Private Properties
    
    private var tabCoordinator: ITabCoordinator
    private let dependencyContainer: IDependencyContainer

    // MARK: - Lifecycle
    
    init(
        window: UIWindow,
        dependencyContainer: IDependencyContainer
    ) {
        self.window = window
        self.dependencyContainer = dependencyContainer
        
        let tabBarController = UITabBarController()
        tabCoordinator = TabCoordinator(
            tabBarController: tabBarController,
            container: dependencyContainer
        )
    }
    
    // MARK: - Public Methods
    
    func start() {
        window.rootViewController = tabCoordinator.tabBarController
        window.makeKeyAndVisible()
        
        tabCoordinator.start()
    }
    
    // MARK: - Private methods
    
}
