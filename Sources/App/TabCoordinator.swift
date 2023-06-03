//
//  MainCoordinator.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import UIKit

protocol ITabCoordinator: AnyObject {
    
    var tabBarController: UITabBarController { get set }
    func start()
    
}

class TabCoordinator: ITabCoordinator {
    
    // MARK: - Public properties
    
    var tabBarController: UITabBarController
    var didFinishClosure: (() -> ())?
    
    // MARK: - Private properties
    
    let container: IDependencyContainer
    let feedCoordinator: IFeedCoordinator
    let profileCoordinator: IProfileCoordinator
    
    // MARK: - Lifecycle
    
    init(tabBarController: UITabBarController, container: IDependencyContainer) {
        self.tabBarController = tabBarController
        self.container = container
        
        let feedNavController = UINavigationController()
        feedNavController.title = nil
        feedNavController.tabBarItem.image = UIImage.image
        feedCoordinator = FeedCoordinator(navigationController: feedNavController, dependancyContainer: container)
        
        let profileNavController = UINavigationController()
        profileNavController.title = nil
        profileNavController.tabBarItem.image = UIImage.user
        profileCoordinator = ProfileCoordinator(navigationController: profileNavController, dependancyContainer: container)
                
        tabBarController.tabBar.backgroundColor = UIColor.TabBar.background
        tabBarController.tabBar.barTintColor = UIColor.TabBar.background
        tabBarController.tabBar.tintColor = UIColor.TabBar.selected
        tabBarController.tabBar.unselectedItemTintColor = UIColor.TabBar.unselected
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.shadowImage = UIImage()
        tabBarController.tabBar.clipsToBounds = true
    }
    
    // MARK: - Public methods
    
    func start() {
        tabBarController.setViewControllers(
            [
                feedCoordinator.navigationController,
                profileCoordinator.navigationController
            ],
            animated: false
        )
        
        feedCoordinator.start()
        profileCoordinator.start()
    }
    
}
