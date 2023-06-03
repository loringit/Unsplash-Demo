//
//  FeedCoordinator.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import Combine
import UIKit

enum FeedCoordinatorOut {
    
    
    
}

protocol IFeedCoordinator: AnyObject {
    
    var navigationController: UINavigationController { get }
    func start()
    var out: ((FeedCoordinatorOut) -> ())? { get set }
    
}

class FeedCoordinator: IFeedCoordinator {
    
    // MARK: - Public properties
    
    let navigationController: UINavigationController
    var out: ((FeedCoordinatorOut) -> ())?
    
    // MARK: - Private properties
    
    private var dependancyContainer: IDependencyContainer
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(navigationController: UINavigationController, dependancyContainer: IDependencyContainer) {
        self.navigationController = navigationController
        self.dependancyContainer = dependancyContainer
    }
    
    // MARK: - Public methods
    
    func start() {
        
    }
    
}